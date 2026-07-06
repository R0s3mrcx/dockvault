#!/usr/bin/env bats

setup() {
    PROJECT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    SCRIPT="$PROJECT_DIR/scripts/health.sh"
    cd "$PROJECT_DIR"
}

@test "the script exists and is executable" {
    [ -x "$SCRIPT" ]
}

@test "with Docker available, reports the stack as healthy" {
    if command -v docker >/dev/null 2>&1; then
        skip "Docker is not available on this machine"
    fi

    cp .env.example .env
    docker compose up -d
    sleep 10

    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"DockVault stack is healthy"* ]]

    docker compose down -v
    rm -f .env
}
