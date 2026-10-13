-- =============================================================
-- Semana 0 · Verificación del entorno
-- Ejecuta cada bloque conectado a la base indicada (en DBeaver,
-- elige la base en la barra superior antes de correrlo).
-- Si los conteos coinciden, el entorno está listo.
-- =============================================================


-- -------------------------------------------------------------
-- 1) Conectado a la base: pagila
-- -------------------------------------------------------------
SELECT version();  -- debe decir PostgreSQL 18.x

SELECT 'actor'    AS tabla, count(*) AS filas FROM actor     -- 200
UNION ALL SELECT 'film',     count(*) FROM film               -- 1000
UNION ALL SELECT 'customer', count(*) FROM customer           -- 999
UNION ALL SELECT 'store',    count(*) FROM store              -- 500
UNION ALL SELECT 'rental',   count(*) FROM rental             -- 51805
UNION ALL SELECT 'payment',  count(*) FROM payment            -- 51061
ORDER BY tabla;

-- Rango de fechas de los arriendos (aprox. feb 2022 a jul 2026)
SELECT min(rental_date)::date AS primer_arriendo,
       max(rental_date)::date AS ultimo_arriendo
FROM rental;

-- Primera consulta de negocio: las 5 categorías con más arriendos
SELECT c.name      AS categoria,
       count(*)    AS arriendos
FROM rental r
JOIN inventory     i  ON i.inventory_id = r.inventory_id
JOIN film_category fc ON fc.film_id     = i.film_id
JOIN category      c  ON c.category_id  = fc.category_id
GROUP BY c.name
ORDER BY arriendos DESC
LIMIT 5;


-- -------------------------------------------------------------
-- 2) Conectado a la base: northwind
-- -------------------------------------------------------------
SELECT 'customers'     AS tabla, count(*) AS filas FROM customers  -- 91
UNION ALL SELECT 'orders',        count(*) FROM orders             -- 830
UNION ALL SELECT 'order_details', count(*) FROM order_details      -- 2155
UNION ALL SELECT 'products',      count(*) FROM products           -- 77
UNION ALL SELECT 'employees',     count(*) FROM employees          -- 9
ORDER BY tabla;
