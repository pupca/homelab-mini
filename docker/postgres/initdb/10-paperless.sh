#!/bin/sh
# Runs only on first postgres init (empty data dir). Creates the paperless
# database + role. New shared databases can be added as more 20-*.sh scripts.
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<EOSQL
    CREATE ROLE paperless WITH LOGIN PASSWORD '${PAPERLESS_DB_PASS}';
    CREATE DATABASE paperless OWNER paperless;
EOSQL
