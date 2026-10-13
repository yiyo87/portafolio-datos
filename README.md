# Portafolio de datos · Fase 1: SQL y modelado dimensional

Repositorio de práctica para aprender SQL avanzado y modelado dimensional (Kimball) sobre PostgreSQL. Cada carpeta `semanaNN` guarda el entregable de esa semana del plan.

El entorno se levanta con un solo comando: PostgreSQL 18 en Docker, con las bases de ejemplo **Pagila** y **Northwind** ya cargadas.

## Qué incluye

| Ruta | Contenido |
| --- | --- |
| `docker-compose.yml` | Servicio PostgreSQL 18 (imagen oficial de pgvector) |
| `docker/init/01-cargar-bases.sh` | Crea y carga las bases `pagila` y `northwind` la primera vez |
| `docker/datos/` | Scripts SQL de Pagila y Northwind, con sus licencias |
| `csv/` | Carpeta para dejar archivos CSV y cargarlos con `COPY` (semana 5). Dentro del contenedor se ve como `/csv` |
| `semana00/verificacion.sql` | Consultas para comprobar que todo quedó bien cargado |
| `semana01` … `semana10` | Entregables semanales |

## Requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows o macOS) o Docker Engine con Compose (Linux)
- [DBeaver Community](https://dbeaver.io/download/) como cliente SQL
- [Git](https://git-scm.com/) y una cuenta de GitHub

## Puesta en marcha

1. Abre una terminal en esta carpeta.
2. Crea tu archivo de credenciales y cambia la contraseña:

   ```bash
   # macOS / Linux
   cp .env.example .env

   # Windows (PowerShell)
   copy .env.example .env
   ```

3. Levanta el entorno:

   ```bash
   docker compose up -d
   ```

4. Espera a que termine la carga inicial (1–2 minutos la primera vez) y revisa el log:

   ```bash
   docker compose logs -f postgres
   ```

   Cuando aparezca `>> Listo: bases practica, pagila y northwind disponibles` y luego `database system is ready to accept connections`, presiona `Ctrl+C` para salir del log. El contenedor sigue corriendo.

## Conectarse desde DBeaver

1. **Nueva conexión → PostgreSQL**.
2. Datos de conexión:

   | Campo | Valor |
   | --- | --- |
   | Host | `localhost` |
   | Puerto | `5432` (o el `PG_PORT` que pusiste en `.env`) |
   | Base de datos | `pagila` |
   | Usuario | `postgres` |
   | Contraseña | la de tu `.env` |

3. En la pestaña **PostgreSQL**, marca **Show all databases** para ver también `northwind` y `practica`.
4. Si DBeaver pide descargar el driver, acepta.

## Verificar

Abre `semana00/verificacion.sql` en DBeaver y ejecuta cada bloque conectado a la base que indica. Los conteos esperados están comentados al lado de cada consulta.

| Base | Tabla | Filas |
| --- | --- | --- |
| pagila | film | 1000 |
| pagila | customer | 999 |
| pagila | rental | 51805 |
| pagila | payment | 51061 |
| northwind | orders | 830 |
| northwind | order_details | 2155 |

## Comandos útiles

| Acción | Comando |
| --- | --- |
| Detener (los datos se conservan) | `docker compose stop` |
| Volver a iniciar | `docker compose start` |
| Ver el estado | `docker compose ps` |
| Abrir `psql` dentro del contenedor | `docker compose exec postgres psql -U postgres -d pagila` |
| **Borrar todo y recargar desde cero** | `docker compose down -v` y luego `docker compose up -d` |

El script de carga solo corre cuando el volumen está vacío. Si rompes una base practicando, el último comando de la tabla la deja como nueva.

## Subir el repositorio a GitHub

1. Crea en GitHub un repositorio vacío llamado `portafolio-datos` (sin README ni .gitignore).
2. En esta carpeta:

   ```bash
   git init
   git add .
   git commit -m "Semana 0: entorno PostgreSQL con Pagila y Northwind"
   git branch -M main
   git remote add origin https://github.com/<tu-usuario>/portafolio-datos.git
   git push -u origin main
   ```

El archivo `.env` con tu contraseña no se sube: está en `.gitignore`.

## Problemas comunes

- **`port is already allocated` o el puerto 5432 está ocupado.** Ya tienes otro PostgreSQL instalado. Cambia `PG_PORT=5433` en `.env`, ejecuta `docker compose up -d` y usa 5433 en DBeaver.
- **`required variable POSTGRES_PASSWORD is missing`.** Falta el archivo `.env`. Repite el paso 2.
- **El log muestra `/bin/bash^M: bad interpreter` (Windows).** El script quedó con saltos de línea de Windows. El `.gitattributes` del repo lo evita al clonar. Si copiaste los archivos a mano, abre `docker/init/01-cargar-bases.sh` en VS Code, cambia `CRLF` a `LF` en la barra inferior, guarda y ejecuta `docker compose down -v` y `docker compose up -d`.
- **No aparecen `pagila` ni `northwind`.** La carga solo ocurre la primera vez. Revisa `docker compose logs postgres` y, si hubo un error, recarga desde cero con `docker compose down -v`.

## Estructura de cada entregable semanal

Cada carpeta `semanaNN` debería tener:

- Los scripts `.sql` comentados, con la pregunta de negocio arriba de cada consulta.
- Un `README.md` corto: qué practicaste, qué te costó y una consulta de la que estés orgulloso.

## Créditos de los datos

- **Pagila**, de Devrim Gündüz, bajo licencia PostgreSQL. [github.com/devrimgunduz/pagila](https://github.com/devrimgunduz/pagila)
- **Northwind** para PostgreSQL, de pthom. Base original de Microsoft bajo Microsoft Public License. [github.com/pthom/northwind_psql](https://github.com/pthom/northwind_psql)
