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

if command -v supabase >/dev/null 2>&1; then
    echo "Starting Supabase (local)..."
    (cd "$REPO_ROOT" && supabase start) || echo "Supabase start skipped (already running or CLI missing)"
    if [ ! -f "$REPO_ROOT/apps/web/.env" ]; then
        echo "Writing local .env files from supabase status..."
        bash "$REPO_ROOT/scripts/sync-local-env.sh"
    fi
else
    echo "Supabase CLI not found — skip local DB or install: https://supabase.com/docs/guides/cli"
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
