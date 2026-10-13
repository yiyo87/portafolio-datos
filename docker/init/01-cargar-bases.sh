#!/bin/bash
# Crea las bases pagila y northwind y carga sus datos.
# PostgreSQL ejecuta este script automáticamente solo la primera vez que arranca
# con el volumen vacío. Para recargar todo: docker compose down -v && docker compose up -d
set -euo pipefail

DATOS="${DATOS_DIR:-/datos}"
PSQL=(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --no-psqlrc -q)

echo ">> Creando bases pagila y northwind"
"${PSQL[@]}" --dbname postgres <<-SQL
	CREATE DATABASE pagila;
	CREATE DATABASE northwind;
SQL

echo ">> Cargando Pagila (esquema + datos, ~13 MB)"
"${PSQL[@]}" --dbname pagila -f "$DATOS/pagila/pagila-schema.sql" > /dev/null
"${PSQL[@]}" --dbname pagila -f "$DATOS/pagila/pagila-data.sql" > /dev/null

echo ">> Cargando Northwind"
"${PSQL[@]}" --dbname northwind -f "$DATOS/northwind/northwind.sql" > /dev/null

echo ">> Listo: bases practica, pagila y northwind disponibles"
