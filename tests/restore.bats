#!/usr/bin/env bats

setup() {
    PROJECT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    SCRIPT="$PROJECT_DIR/scripts/restore.sh"

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

@test "fails if no backup file is passed" {
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "fails if the backup file does not exist" {
    run bash "$SCRIPT" backup-does-not-exist.tar.gz
    [ "$status" -eq 1 ]
    [[ "$output" == *"Backup file not found"* ]]
}

@test "fails if the .env file does not exist" {
    touch fake-backup.tar.gz
    run bash "$SCRIPT" fake-backup.tar.gz
    [ "$status" -eq 1 ]
    [[ "$output" == *".env file not found"* ]]
}
