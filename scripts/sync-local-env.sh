#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

if ! command -v supabase >/dev/null 2>&1; then
  echo "supabase CLI not found"
  exit 1
fi

eval "$(supabase status -o env)"
API_URL="${API_URL:-http://127.0.0.1:55431}"

cat > apps/web/.env <<EOF
NUXT_PUBLIC_API_URL=http://localhost:8000
NUXT_PUBLIC_SUPABASE_URL=${API_URL}
NUXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=${ANON_KEY}
EOF

cat > services/api/.env <<EOF
SUPABASE_URL=${API_URL}
SUPABASE_SECRET_KEY=${SERVICE_ROLE_KEY}
CORS_ORIGINS=http://localhost:3000
EOF

echo "Wrote apps/web/.env and services/api/.env from supabase status"
