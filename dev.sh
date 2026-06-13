#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
PIDS=()

cleanup() {
    echo ""
    echo "Stopping all processes..."
    for pid in "${PIDS[@]}"; do
        kill -- -"$pid" 2>/dev/null || kill "$pid" 2>/dev/null || true
    done
    wait 2>/dev/null
    echo "Done."
}

trap cleanup INT TERM

if [ -f "$REPO_ROOT/apps/web/.env" ] && [ -f "$REPO_ROOT/services/api/.env" ]; then
    echo "Using apps/web/.env and services/api/.env"
elif [ "${LOCAL_SUPABASE:-}" = "1" ] && command -v supabase >/dev/null 2>&1; then
    echo "Starting Supabase (local)..."
    (cd "$REPO_ROOT" && supabase start)
    echo "Writing local .env files from supabase status..."
    bash "$REPO_ROOT/scripts/sync-local-env.sh"
else
    echo "Missing .env files. Copy apps/web/.env.example and services/api/.env.example, then fill in your Supabase keys."
    echo "For local Supabase instead: LOCAL_SUPABASE=1 pnpm dev"
    exit 1
fi

if [ ! -d "$REPO_ROOT/node_modules" ]; then
    echo "Installing JS dependencies..."
    (cd "$REPO_ROOT" && pnpm install)
fi

echo "Starting API (FastAPI)..."
(cd "$REPO_ROOT/services/api" && set -a && [ -f .env ] && source .env; set +a && uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload) &
PIDS+=($!)

echo "Starting Web (Nuxt)..."
(cd "$REPO_ROOT" && pnpm --filter web dev) &
PIDS+=($!)

echo ""
echo "Web:  http://localhost:3000"
echo "API:  http://localhost:8000"
echo "Press Ctrl+C to stop."
wait
