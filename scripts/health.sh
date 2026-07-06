#!/bin/bash

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed"
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "Docker is not running"
    exit 1
fi

RUNNING_SERVICES=$(docker compose ps --services --filter "status=running")

for SERVICE in api db; do
    if ! echo "$RUNNING_SERVICES" | grep -q "^$SERVICE$"; then
        echo "$SERVICE service is not running"
        exit 1
    fi
done

if [ ! -f .env ]; then
    echo ".env file not found. Copy .env.example to .env first."
    exit 1
fi

source .env

if ! curl -fs "http://localhost:$API_PORT/" >/dev/null; then
    echo "API is not responding"
    exit 1
fi

if ! docker compose exec -T db pg_isready -U "$POSTGRES_USER" >/dev/null 2>&1; then
    echo "Database is not responding"
    exit 1
fi

echo "DockVault stack is healthy"

exit 0
