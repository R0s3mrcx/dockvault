#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./restore.sh <backup-file.tar.gz>"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup file not found: $BACKUP_FILE"
    exit 1
fi

if [ ! -f .env ]; then
    echo ".env file not found. Copy .env.example to .env first."
    exit 1
fi

source .env

echo "Extracting backup..."

tar -xzf "$BACKUP_FILE" -C /tmp

SQL_FILE=$(basename "$BACKUP_FILE" .tar.gz).sql

echo "Restoring database from $SQL_FILE..."

if docker compose exec -T db psql -U "$POSTGRES_USER" "$POSTGRES_DB" < "/tmp/$SQL_FILE"; then
    echo "Restore successful"
else
    echo "Restore failed"
    exit 1
fi

rm "/tmp/$SQL_FILE"

exit 0
