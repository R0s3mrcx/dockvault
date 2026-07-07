# DockVault

![CI](https://github.com/r0s3mrcx/dockvault/actions/workflows/ci.yml/badge.svg)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-0078D4?logo=microsoftazure&logoColor=white)
![License](https://img.shields.io/github/license/r0s3mrcx/dockvault)

A containerized PostgreSQL stack with automated backup, restore, and health check scripts.

The project combines Docker Compose, Bash, PostgreSQL, Azure Blob Storage, automated testing, and GitHub Actions into a small operational workflow.

# Architecture

```
             Docker Compose
                    │
        ┌───────────┴───────────┐
        ▼                       ▼
  Flask API               PostgreSQL
        │                       │
        └───────────┬───────────┘
                    ▼
             Docker Network
                    │
                    ▼
             Named Volume

         Backup / Restore / Health
                    │
                    ▼
          Azure Blob Storage
```

# Components

## API

- Flask application
- PostgreSQL backend
- Environment-based configuration
- REST endpoints for creating and listing items


## Database

- PostgreSQL 16
- Persistent named Docker volume
- Built-in health check


## Operations

The project includes three operational scripts.

### backup.sh

- Creates a PostgreSQL dump
- Compresses it as `.tar.gz`
- Optionally uploads it to Azure Blob Storage

```bash
./scripts/backup.sh --local-only

./scripts/backup.sh
```

### restore.sh

Restores a compressed backup into PostgreSQL.

```bash
./scripts/restore.sh backups/backup-YYYY-MM-DD-HH-MM.tar.gz
```

### health.sh

Performs a basic health check by verifying:

- Docker
- Running containers
- Flask API
- PostgreSQL

Returns:

- Exit code `0` → Stack is healthy
- Exit code `1` → One or more checks failed

```bash
./scripts/health.sh
```

# Project Structure

```
dockvault/
│
├── app/
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── .dockerignore
│
├── scripts/
│   ├── backup.sh
│   ├── restore.sh
│   └── health.sh
│
├── tests/
│   ├── backup.bats
│   ├── restore.bats
│   └── health.bats
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── compose.yml
├── .env.example
├── README.md
├── LICENSE
└── .gitignore
```

# Requirements

- Docker Engine
- Docker Compose
- Bash
- Azure CLI (only for Azure uploads)

# How to Run

Clone the repository.

```bash
git clone https://github.com/r0s3mrcx/dockvault.git

cd dockvault
```

Create the environment file.

```bash
cp .env.example .env
```

Start the stack.

```bash
docker compose up -d
```

# Environment Variables

| Name | Description | Default |
|---|---|---|
| POSTGRES_USER | Database user | dockvault |
| POSTGRES_PASSWORD | Database password | changeme |
| POSTGRES_DB | Database name | dockvault |
| POSTGRES_HOST | Database host | db |
| POSTGRES_PORT | Database port | 5432 |
| API_PORT | API port | 5000 |


# API

Health endpoint

```bash
curl http://localhost:5000/
```

Create an item

```bash
curl -X POST http://localhost:5000/items \
-H "Content-Type: application/json" \
-d '{"name":"example"}'
```

List items

```bash
curl http://localhost:5000/items
```

# Testing

Run the Bats test suite.

```bash
bats tests/
```

The tests verify:

- exit codes
- argument validation
- backup creation
- restore validation
- health checks


# CI

Every push runs a GitHub Actions workflow that:

1. Runs ShellCheck
2. Executes the Bats test suite
3. Validates the Compose configuration

The workflow validates the project without deploying infrastructure or requiring Azure credentials.


# License

This project is licensed under the MIT License.

See the LICENSE file for details.
