#!/usr/bin/env sh
set -e

OPTS="/app/data/options.json"

# Defaults
LOG_LEVEL="info"
JWT_SECRET=""
DEFAULT_ADMIN_USERNAME="admin"
DEFAULT_ADMIN_PASSWORD=""
DEFAULT_ADMIN_EMAIL="admin@localhost"
FREEBOX_HOST=""

if [ -f "$OPTS" ]; then
  LOG_LEVEL="$(jq -r '.log_level // "info"' "$OPTS")"
  JWT_SECRET="$(jq -r '.jwt_secret // ""' "$OPTS")"
  DEFAULT_ADMIN_USERNAME="$(jq -r '.default_admin_username // "admin"' "$OPTS")"
  DEFAULT_ADMIN_PASSWORD="$(jq -r '.default_admin_password // ""' "$OPTS")"
  DEFAULT_ADMIN_EMAIL="$(jq -r '.default_admin_email // "admin@localhost"' "$OPTS")"
  FREEBOX_HOST="$(jq -r '.freebox_host // ""' "$OPTS")"
fi

export PORT=3000
export NODE_ENV=production
export DOCKER=true

# Persistence (IMPORTANT: /app/data)
export DATABASE_PATH="/app/data/dashboard.db"
export CONFIG_FILE_PATH="/app/data/mynetwork.conf"
export FREEBOX_TOKEN_FILE="/app/data/freebox_token.json"

# Secrets / auth
export JWT_SECRET
export DEFAULT_ADMIN_USERNAME
export DEFAULT_ADMIN_PASSWORD
export DEFAULT_ADMIN_EMAIL

# Optional
[ -n "$FREEBOX_HOST" ] && export FREEBOX_HOST

# Ingress: do not set PUBLIC_URL by default
unset PUBLIC_URL || true

# Start upstream (handles chown /app/data + su-exec node)
exec /app/docker-entrypoint.sh node_modules/.bin/tsx server/index.ts
