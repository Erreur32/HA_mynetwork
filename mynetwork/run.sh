#!/usr/bin/env sh
set -e

# Log to stderr so it appears in the add-on Log tab (stdout may be buffered or used by the app)
log() { echo "[MynetworK add-on] $*" >&2; }

log "Starting MynetworK add-on wrapper..."

# Supervisor mounts add-on data at /data (see config.yaml map path: /data) so /app stays from the image
OPTS="/data/options.json"

# Defaults
LOG_LEVEL="info"
# Port is fixed at 3000 (managed by Supervisor via ingress_port, not user-configurable)
SERVER_PORT="3000"
JWT_SECRET=""
DEFAULT_ADMIN_USERNAME="admin"
DEFAULT_ADMIN_PASSWORD=""
DEFAULT_ADMIN_EMAIL="admin@localhost"
FREEBOX_HOST=""

if [ -f "$OPTS" ]; then
  log "Reading options from $OPTS"
  if command -v jq >/dev/null 2>&1; then
    LOG_LEVEL="$(jq -r '.log_level // "info"' "$OPTS" 2>/dev/null)" || true
    # Port is fixed (ingress_port: 3000 in config.yaml); ignore any user value
    JWT_SECRET="$(jq -r '.jwt_secret // ""' "$OPTS" 2>/dev/null)" || true
    DEFAULT_ADMIN_USERNAME="$(jq -r '.default_admin_username // "admin"' "$OPTS" 2>/dev/null)" || true
    DEFAULT_ADMIN_PASSWORD="$(jq -r '.default_admin_password // ""' "$OPTS" 2>/dev/null)" || true
    DEFAULT_ADMIN_EMAIL="$(jq -r '.default_admin_email // "admin@localhost"' "$OPTS" 2>/dev/null)" || true
    FREEBOX_HOST="$(jq -r '.freebox_host // ""' "$OPTS" 2>/dev/null)" || true
  else
    log "WARNING: jq not found, using defaults"
  fi
else
  log "No options file at $OPTS, using defaults"
fi

# Normalize log_level (options may send "Debug" or "debug") and export for app / debug block below
LOG_LEVEL="$(echo "$LOG_LEVEL" | tr '[:upper:]' '[:lower:]')"
export LOG_LEVEL

# Port: from option network.server_port (default 3000). Ingress and watchdog use 3000 in the manifest; keep 3000 for standard use.
export PORT="${SERVER_PORT:-3000}"
export DASHBOARD_PORT="${SERVER_PORT:-3000}"
export NODE_ENV=production
export DOCKER=true

# Ingress: app is reached via HA reverse proxy; use relative URLs so the frontend works (no localhost in banner).
# The app receives X-Ingress-Path on each request; upstream MynetworK should use it or relative paths.
export ADDON_INGRESS=1
export INGRESS_MODE=1

# Persistence: use /data (Supervisor mount), not /app/data, so /app from image is untouched
export DATABASE_PATH="/data/dashboard.db"
export CONFIG_FILE_PATH="/data/mynetwork.conf"
export FREEBOX_TOKEN_FILE="/data/freebox_token.json"

# Secrets / auth
export JWT_SECRET
export DEFAULT_ADMIN_USERNAME
export DEFAULT_ADMIN_PASSWORD
export DEFAULT_ADMIN_EMAIL

# Optional
[ -n "$FREEBOX_HOST" ] && export FREEBOX_HOST

# Ingress: leave PUBLIC_URL unset so the app uses relative URLs (required for Ingress to avoid white page).
unset PUBLIC_URL || true

# When log_level=debug: more verbose Node (stack traces) and enable server WebSocket upgrade logging
if [ "$LOG_LEVEL" = "debug" ]; then
  export DEBUG_UPGRADE=true
  # Better stack traces on crash (Node.js)
  NODE_OPTIONS="${NODE_OPTIONS:+$NODE_OPTIONS }--trace-warnings --trace-uncaught"
  export NODE_OPTIONS
  log "Debug mode ON: NODE_OPTIONS=$NODE_OPTIONS DEBUG_UPGRADE=true"
fi

# Ensure we are in app directory; /data is the Supervisor mount (options and persistence)
cd /app 2>/dev/null || true
mkdir -p /data
if [ -w /data ] && command -v chown >/dev/null 2>&1; then
  NODE_UID="${NODE_UID:-1000}"
  NODE_GID="${NODE_GID:-1000}"
  chown -R "${NODE_UID}:${NODE_GID}" /data 2>/dev/null || true
  chmod -R 755 /data 2>/dev/null || true
fi

# Fix Ingress: upstream vite build uses absolute paths (/assets/...) in index.html.
# Ingress reverse proxy prefixes all URLs with /api/hassio_ingress/<token>/, so absolute
# paths break (browser loads /assets/... instead of /api/hassio_ingress/.../assets/...).
# Patch: replace "/assets/" with "./assets/" so paths are relative to the current URL.
INDEX_HTML="/app/dist/index.html"
if [ -f "$INDEX_HTML" ]; then
  if grep -q '"/assets/' "$INDEX_HTML" 2>/dev/null || grep -q "'/assets/" "$INDEX_HTML" 2>/dev/null; then
    log "Patching index.html: absolute /assets/ → relative ./assets/ (Ingress fix)"
    # sed -i needs write permission; image files may be read-only → use tmp + mv
    TMP_HTML="/tmp/index.html.patched"
    sed 's|"/assets/|"./assets/|g' "$INDEX_HTML" | sed "s|'/assets/|'./assets/|g" > "$TMP_HTML"
    cp "$TMP_HTML" "$INDEX_HTML" 2>/dev/null || { chmod u+w "$INDEX_HTML" && cp "$TMP_HTML" "$INDEX_HTML"; }
    rm -f "$TMP_HTML"
    log "index.html patched OK"
  fi
fi

# Start app: use upstream entrypoint if present, else run tsx directly (with su-exec if available)
TSX_CMD="/app/node_modules/.bin/tsx"
SERVER_FILE="/app/server/index.ts"

if [ ! -x "$TSX_CMD" ] && [ -x "/app/node_modules/.bin/tsx" ]; then
  TSX_CMD="/app/node_modules/.bin/tsx"
fi
if [ ! -f "$SERVER_FILE" ]; then
  log "ERROR: Server file not found: $SERVER_FILE"
  log "List /app: $(ls -la /app 2>/dev/null || true)"
  log "List /app/server: $(ls -la /app/server 2>/dev/null || true)"
  exit 1
fi
if [ ! -x "$TSX_CMD" ]; then
  log "ERROR: tsx not found or not executable: $TSX_CMD"
  log "List /app/node_modules/.bin: $(ls -la /app/node_modules/.bin 2>/dev/null || true)"
  exit 1
fi

# Debug mode: dump env and paths so add-on Log tab shows why startup might fail
if [ "$LOG_LEVEL" = "debug" ]; then
  log "--- DEBUG env ---"
  log "PORT=$PORT ADDON_INGRESS=$ADDON_INGRESS NODE_ENV=$NODE_ENV DOCKER=$DOCKER"
  log "DATABASE_PATH=$DATABASE_PATH CONFIG_FILE_PATH=$CONFIG_FILE_PATH FREEBOX_TOKEN_FILE=$FREEBOX_TOKEN_FILE"
  log "JWT_SECRET set=$([ -n "$JWT_SECRET" ] && echo yes || echo no) DEFAULT_ADMIN_USERNAME=$DEFAULT_ADMIN_USERNAME"
  log "LOG_LEVEL=$LOG_LEVEL"
  log "--- DEBUG paths ---"
  log "PWD=$(pwd)"
  log "/app: $(ls -la /app 2>/dev/null | head -20)"
  log "/data: $(ls -la /data 2>/dev/null | head -15)"
  log "/app/server (first): $(ls /app/server 2>/dev/null | head -5)"
  log "--- DEBUG end ---"
fi

# In add-on context, do not use su-exec or docker-entrypoint.sh: setgroups() is denied
# (AppArmor / restricted container) → "su-exec: setgroups: Operation not permitted".
# Skip the upstream entrypoint entirely and run the process directly.
if [ -n "$ADDON_INGRESS" ] && [ "$ADDON_INGRESS" = "1" ]; then
  log "Starting directly (add-on, no su-exec, no docker-entrypoint.sh): $TSX_CMD $SERVER_FILE"
  exec "$TSX_CMD" "$SERVER_FILE"
fi

if [ -x "/app/docker-entrypoint.sh" ]; then
  log "Starting via /app/docker-entrypoint.sh (tsx server/index.ts)"
  exec /app/docker-entrypoint.sh "$TSX_CMD" "server/index.ts"
fi

if command -v su-exec >/dev/null 2>&1 && id node >/dev/null 2>&1; then
  log "Starting via su-exec node $TSX_CMD $SERVER_FILE"
  exec su-exec node "$TSX_CMD" "$SERVER_FILE"
fi

log "Starting directly: $TSX_CMD $SERVER_FILE"
exec "$TSX_CMD" "$SERVER_FILE"
