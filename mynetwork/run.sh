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

# Ensure we are in app directory and /app/data exists with correct permissions
cd /app 2>/dev/null || true
mkdir -p /app/data
if [ -w /app/data ] && command -v chown >/dev/null 2>&1; then
  NODE_UID="${NODE_UID:-1000}"
  NODE_GID="${NODE_GID:-1000}"
  chown -R "${NODE_UID}:${NODE_GID}" /app/data 2>/dev/null || true
  chmod -R 755 /app/data 2>/dev/null || true
fi

# Start app: use upstream entrypoint if present, else run tsx directly (with su-exec if available)
TSX_CMD="node_modules/.bin/tsx"
SERVER_ARGS="server/index.ts"

if [ -x "/app/docker-entrypoint.sh" ]; then
  exec /app/docker-entrypoint.sh "$TSX_CMD" $SERVER_ARGS
fi

if command -v su-exec >/dev/null 2>&1 && id node >/dev/null 2>&1; then
  exec su-exec node "$TSX_CMD" $SERVER_ARGS
fi

# Fallback: run tsx as current user (e.g. when entrypoint/su-exec/node user not in image)
exec "$TSX_CMD" $SERVER_ARGS
