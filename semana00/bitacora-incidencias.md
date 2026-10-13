# Bitácora de incidencias · portafolio-datos

Registro de los problemas que aparecen al trabajar en el proyecto: qué pasó, por qué pasó, cómo se diagnosticó y cómo se resolvió. Sirve para aprender el método de diagnóstico, no solo la solución.

| # | Fecha | Semana | Incidencia | Estado |
| --- | --- | --- | --- | --- |
| 1 | 2026-10-13 | 0 | Pagila exige PostgreSQL 18 y la extensión `vector` | Resuelta |
| 2 | 2026-10-13 | 0 | "El log de transacciones no está disponible" en DBeaver | Resuelta |
| 3 | 2026-10-13 | 0 | Nunca se definió la contraseña: faltaba el archivo `.env` | Resuelta |
| 4 | 2026-10-13 | 0 | "No active connection" al ejecutar el script | Resuelta |
| 5 | 2026-10-13 | 0 | `relation "actor" does not exist` | Resuelta |
| 6 | 2026-10-13 | 0 | El selector de DBeaver solo mostraba `public` | Resuelta |
| 7 | 2026-10-13 | 0 | Error en el bloque 2 (Northwind) tras cambiar de base | Resuelta |

---

## 1. Pagila exige PostgreSQL 18 y la extensión `vector`

**Síntoma.** Al probar la carga de Pagila en PostgreSQL 16 aparecieron dos errores:

```
ERROR:  function uuidv7() does not exist
ERROR:  extension "vector" is not available
```

**Causa.** La versión actual de Pagila usa funciones nuevas de PostgreSQL 18, como `uuidv7()`, y una tabla con el tipo `vector`, que viene de la extensión pgvector. La imagen `postgres:16` no tiene ninguna de las dos cosas.

**Diagnóstico.** Se leyó el README de Pagila, que dice: "Pagila has been tested against PostgreSQL 18 and above". El `Dockerfile` del mismo repositorio instala `postgresql-18-pgvector`.

**Solución.** Se cambió la imagen en `docker-compose.yml` a `pgvector/pgvector:pg18-trixie`, que trae PostgreSQL 18 con pgvector. También se cambió el volumen a `/var/lib/postgresql`, que es la ruta que espera PostgreSQL 18.

**Lección.** Antes de cargar un dataset, lee su README y fíjate en la versión mínima y en las extensiones que pide. Un error `function ... does not exist` o `extension ... is not available` casi siempre significa que el motor es más antiguo de lo necesario o que falta una extensión.

---

## 2. "El log de transacciones no está disponible"

**Síntoma.** Al hacer clic en el recuadro **N/A** de la barra de DBeaver apareció:

```
No conectado a la base de datos
El log de transacciones no está disponible. Conéctese a una base de datos.
```

**Causa.** Fue un error de la instrucción: ese recuadro **N/A** es el monitor de transacciones, no el selector de conexión.

**Solución.** Se cerró el aviso. Los selectores correctos son los dos de la derecha: el del **elefante** (la conexión) y el del **cilindro** (la base y el esquema).

**Lección.** En la barra de DBeaver:

| Control | Para qué sirve |
| --- | --- |
| `Auto` / `N/A` (recuadro blanco) | Modo de transacción y registro de transacciones |
| Elefante + nombre (`postgres`) | Conexión activa del script (atajo **Ctrl+9**) |
| Cilindro + `esquema@base` (`public@pagila`) | Base y esquema activos (atajo **Ctrl+0**) |

---

## 3. Nunca se definió la contraseña: faltaba el archivo `.env`

**Síntoma.** El README decía que la contraseña de DBeaver debía ser la del `.env`, pero nunca se había definido ninguna. Se probó con la contraseña del sistema.

**Causa.** El archivo `.env` no existía, solo `.env.example`. Sin `.env`, Docker Compose no puede leer `POSTGRES_PASSWORD` y no levanta el contenedor:

```
required variable POSTGRES_PASSWORD is missing a value
```

**Diagnóstico.** Se revisó la carpeta del proyecto y solo estaba `.env.example`.

**Solución.**

1. Copiar `.env.example` a `.env`.
2. Cambiar `POSTGRES_PASSWORD` por una contraseña propia.
3. Ejecutar `docker compose up -d` desde `D:\portafolio-datos`.
4. Usar esa misma contraseña en DBeaver.

**Lección.** `.env.example` es una plantilla que se sube a GitHub. `.env` es tu copia local con secretos y nunca se sube. PostgreSQL guarda la contraseña **la primera vez** que arranca con el volumen vacío. Si después la cambias en `.env`, no se actualiza sola: hay que recrear el volumen con `docker compose down -v` y luego `docker compose up -d`.

---

## 4. "No active connection" al ejecutar el script

**Síntoma.**

```
No se puede obtener una sesión
No active connection
```

**Causa.** El script no estaba asociado a ninguna conexión. La pestaña decía `<none> verificacion.sql` y el selector mostraba `< N/A >`.

**Diagnóstico.** El prefijo de la pestaña del editor indica la conexión: `<none>` significa que no hay ninguna.

**Solución.** Hacer doble clic en la conexión `postgres` del panel izquierdo para abrirla, y elegirla en el selector del elefante (**Ctrl+9**). La pestaña pasó a `<postgres> verificacion.sql`.

**Lección.** Antes de ejecutar, revisa el prefijo de la pestaña (`<conexión>`) y el selector `esquema@base`. Ahí está el contexto en que va a correr la consulta.

---

## 5. `relation "actor" does not exist`

**Síntoma.**

```
SQL Error [42P01]: ERROR: relation "actor" does not exist
Position: 85
```

**Causa.** Hubo dos problemas juntos:

1. La conexión apuntaba a la base `postgres` (selector `public@postgres`), que viene vacía. La tabla `actor` está en `pagila`.
2. Se ejecutó con **Ctrl+Enter** con dos sentencias seleccionadas. DBeaver las mandó como una sola consulta: en el log aparecía `SELECT version(); ... SELECT 'actor' ...` en una sola fila.

**Diagnóstico.** El código `42P01` significa "la tabla no existe en esta base". Cuando aparece con una tabla que sabes que existe, lo primero es revisar a qué base estás conectado.

**Solución.** Cambiar a `public@pagila` y ejecutar con **Alt+X** (ejecutar script), que corre cada sentencia por separado.

**Lección.**

| Atajo | Qué ejecuta |
| --- | --- |
| **Ctrl+Enter** | La sentencia donde está el cursor, o la selección como una sola consulta |
| **Alt+X** | Cada sentencia por separado, con una pestaña de resultados por cada una |

---

## 6. El selector de DBeaver solo mostraba `public`

**Síntoma.** Al abrir el selector `public@postgres` solo aparecía el esquema `public`. Parecía que `pagila` y `northwind` no existían.

**Causa.** Por defecto, DBeaver muestra solo la base configurada en la conexión. Las demás bases existían, pero estaban ocultas.

**Diagnóstico.** Se descartaron hipótesis con dos consultas, en vez de adivinar:

```sql
SELECT version();
-- PostgreSQL 18.6 (Debian ...) on x86_64-pc-linux-gnu
-- => es el PostgreSQL de Docker, no uno instalado en Windows

SELECT datname FROM pg_database ORDER BY datname;
-- northwind, pagila, postgres, practica, template0, template1
-- => la carga funcionó; las bases existen
```

| Si `version()` dice... | Significa |
| --- | --- |
| `linux-gnu`, `Debian` | Conectado al contenedor Docker |
| `Visual C++`, `Windows` | Conectado a un PostgreSQL instalado en Windows; hay un conflicto de puerto |

**Solución.** En Editar conexión (**F4**), pestaña **PostgreSQL**, marcar **Show all databases**. Después se pudo elegir `public@pagila`. Con eso, el bloque 1 dio los resultados esperados, por ejemplo New 8.088, Sci-Fi 8.007 y Documentary 7.976 en el top de categorías.

**Lección.** Ante un problema de conexión, pregúntale a la base en vez de confiar en lo que muestra la interfaz. `version()` dice a qué servidor estás conectado y `pg_database` dice qué bases existen.

---

## 7. Error en el bloque 2 (Northwind) tras cambiar de base

**Síntoma.** En el log de ejecución apareció una fila roja con `SELECT 'customers' AS tabla, count(*) ...`, con una duración de 0,002 s.

**Causa.** Esa ejecución ocurrió antes de que el selector quedara en `public@northwind`, cuando todavía estaba en `pagila`. Pagila tiene una tabla `customer` (en singular), pero no `customers`, así que la consulta falla con `relation "customers" does not exist`. Un error de 0,002 s indica que la consulta se rechazó antes de leer datos.

**Evidencia.** Las dos ejecuciones siguientes del mismo bloque, ya con `public@northwind`, aparecen sin error en el log.

**Resolución.** La consulta sí se había ejecutado bien. El resultado no se veía porque había quedado en otra pestaña: al ejecutar con Alt+X una selección de tres sentencias, DBeaver abrió tres pestañas (`Resultados 1`, `Resultados 1 (2)` y `pg_database 1 (3)`), y en pantalla quedó visible la última. En la pestaña **Resultados 1** estaban los conteos esperados: customers 91, employees 9, order_details 2.155, orders 830 y products 77. La fila roja del log correspondía al intento anterior, hecho todavía sobre `pagila`.

**Lección adicional.** Con Alt+X, cada sentencia genera su propia pestaña de resultados, y DBeaver muestra la última. Antes de concluir que algo falló, revisa todas las pestañas de resultados.

**Lección.** Cuando una consulta falla y la siguiente funciona, revisa la hora de cada fila del log. A menudo el error corresponde a un intento anterior, hecho con un contexto distinto (otra base u otro esquema).

---

## Checklist rápido: "mi consulta no funciona en DBeaver"

1. ¿La pestaña dice `<postgres>` y no `<none>`?
2. ¿El selector dice la base correcta (`public@pagila` o `public@northwind`)?
3. ¿Docker está arriba? Ejecuta `docker compose ps` y busca `pg-practica` con estado `Up (healthy)`.
4. ¿Estás en el servidor correcto? Ejecuta `SELECT version();` y busca `linux-gnu`.
5. ¿La base existe? Ejecuta `SELECT datname FROM pg_database;`.
6. ¿Ejecutaste varias sentencias con Ctrl+Enter? Usa Alt+X.
7. ¿La contraseña falla? Debe ser la del `.env`. Si la cambiaste después del primer arranque, ejecuta `docker compose down -v` y luego `docker compose up -d`.
