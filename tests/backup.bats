#!/usr/bin/env bats

setup() {
    PROJECT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    SCRIPT="$PROJECT_DIR/scripts/backup.sh"

    cd "$PROJECT_DIR"
    rm -f .env
    rm -rf backups
}

teardown() {
    docker compose down -v >/dev/null 2>&1 || true
    rm -f .env
    rm -rf backups
}

@test "the script exists and is executable" {
    [ -x "$SCRIPT" ]
}

@test "fails if the .env file does not exist" {
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *".env file not found"* ]]
}

@test "with Docker available, creates a real backup with --local-only" {
    if ! command -v docker >/dev/null 2>&1; then
        skip "Docker is not available on this machine"
    fi

    cp .env.example .env
    docker compose -f "$PROJECT_DIR/compose.yml" up -d db
    sleep 5

    run bash "$SCRIPT" --local-only
    echo "STATUS=$status"
    echo "$output"

    [ "$status" -eq 0 ]

    count=$(ls backups/backup-*.tar.gz | wc -l)
    [ "$count" -eq 1 ]

    docker compose -f "$PROJECT_DIR/compose.yml" down -v
}
