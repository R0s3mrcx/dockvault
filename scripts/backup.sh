#!/bin/bash

if [ ! -f .env ]; then
    echo ".env file not found. Copy .env.example to .env first."
    exit 1
fi

source .env

DATE=$(date +%Y-%m-%d-%H-%M)
SQL_FILE="backup-$DATE.sql"
BACKUP_NAME="backup-$DATE.tar.gz"

mkdir -p backups

echo "Creating database dump..."

if docker compose exec -T db pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > "backups/$SQL_FILE"; then
    echo "Database dump created: $SQL_FILE"
else
    echo "Database dump failed"
    exit 1
fi

echo "Compressing backup..."

tar -czf "backups/$BACKUP_NAME" -C backups "$SQL_FILE"

rm "backups/$SQL_FILE"

echo "Backup created: $BACKUP_NAME"

if [ "$1" = "--local-only" ]; then
    echo "Local only mode. Skipping upload."
    exit 0
fi

echo "Uploading to Azure..."

if az storage blob upload \
    --container-name backups \
    --file "backups/$BACKUP_NAME" \
    --name "$BACKUP_NAME"; then
    echo "Upload successful"
else
    echo "Upload failed"
    exit 1
fi

exit 0
