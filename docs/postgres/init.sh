#!/bin/bash
set -e

echo "[INFO] Creating database 'tomo' ..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE tomo;
EOSQL

echo "[INFO] Installing PostgreSQL extensions ..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname=tomo <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS postgis;
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS pg_trgm;
    CREATE EXTENSION IF NOT EXISTS unaccent;
EOSQL

echo "[INFO] Database initialization completed ..."
