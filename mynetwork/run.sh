#!/usr/bin/env sh
set -e

# Log to stderr so it appears in the add-on Log tab (stdout may be buffered or used by the app)
log() { echo "[MynetworK add-on] $*" >&2; }

log "Starting MynetworK add-on wrapper..."

# Supervisor mounts add-on data at /data (see config.yaml map path: /data) so /app stays from the image
OPTS="/data/options.json"

# Defaults (infrastructure only — admin credentials are managed by the app itself, not HA config)
LOG_LEVEL="info"
# Port is fixed at 3000 (managed by Supervisor via ingress_port, not user-configurable)
SERVER_PORT="3000"
JWT_SECRET=""
FREEBOX_HOST=""

if [ -f "$OPTS" ]; then
  log "Reading options from $OPTS"
  if command -v jq >/dev/null 2>&1; then
    LOG_LEVEL="$(jq -r '.log_level // "info"' "$OPTS" 2>/dev/null)" || true
    # Port is fixed (ingress_port: 3000 in config.yaml); ignore any user value
    JWT_SECRET="$(jq -r '.jwt_secret // ""' "$OPTS" 2>/dev/null)" || true
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

# Secrets / auth (only JWT — admin credentials are managed by the app via its own DB)
export JWT_SECRET

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

# Copy default files from image into /data (first run only — don't overwrite existing).
# The Dockerfile already created /app/data as a symlink → /data, so upstream code
# that writes to /app/data/ actually writes to the persistent Supervisor volume.
# /app/data_defaults/ holds files that were originally in the image's /app/data/.
if [ -d "/app/data_defaults" ]; then
  cp -rn /app/data_defaults/* /data/ 2>/dev/null || true
  log "Default data files copied to /data"
fi

# ── Ingress compatibility: comprehensive index.html patching ─────────────
#
# Home Assistant Ingress reverse-proxies requests through:
#   /api/hassio_ingress/<session_token>/...
#
# The upstream Vite build has TWO problems under Ingress:
#
#   1. HTML references assets with absolute paths (/assets/index-xxx.js).
#      The browser resolves these to http://HA:8123/assets/... (HA host root)
#      instead of http://HA:8123/api/hassio_ingress/<token>/assets/...
#      → FIX: replace "/assets/" with "./assets/" (relative to current URL).
#
#   2. The JavaScript bundle makes API calls (fetch("/api/...")) and opens
#      WebSocket connections (new WebSocket("/ws/...")) using absolute paths.
#      These also bypass the Ingress proxy and hit HA's own API or 404.
#      → FIX: inject a small "shim" <script> at the top of <head> that
#        overrides window.fetch, XMLHttpRequest.open, and WebSocket so that
#        any URL starting with "/" is transparently prefixed with the Ingress
#        base path (e.g. /api/hassio_ingress/abc123).  When not running
#        under Ingress the shim detects this and does nothing (safe no-op).
#
INDEX_HTML="/app/dist/index.html"
if [ -f "$INDEX_HTML" ]; then
  log "Applying Ingress patches to index.html..."
  TMP_HTML="/tmp/index.html.patched"
  cp "$INDEX_HTML" "$TMP_HTML"

  # ── Fix 1: asset paths  /assets/ → ./assets/ ──────────────────────
  sed -i 's|"/assets/|"./assets/|g' "$TMP_HTML" 2>/dev/null || true
  sed -i "s|'/assets/|'./assets/|g" "$TMP_HTML" 2>/dev/null || true

  # ── Fix 2: inject Ingress shim (idempotent — skipped if already present) ──
  if ! grep -q 'data-ingress-shim' "$TMP_HTML" 2>/dev/null; then

    # Write the shim HTML to a temp file (heredoc with 'EOF' = no shell expansion)
    cat > /tmp/ingress-shim.html << 'SHIMEOF'
<script data-ingress-shim>
/* HA Ingress URL rewriter – intercepts browser APIs so absolute paths
   like /api/... and /ws/... are routed through the Ingress reverse proxy.
   When the page is NOT loaded via Ingress the shim is a harmless no-op. */
(function(){
  var m=window.location.pathname.match(/^\/api\/hassio_ingress\/[^\/]+/);
  if(!m)return;
  var B=m[0];
  function fix(u){return(typeof u==="string"&&u.charAt(0)==="/"&&!u.startsWith(B))?B+u:u;}

  /* fetch() */
  var _f=window.fetch;
  window.fetch=function(u,o){return _f.call(this,fix(u),o);};

  /* XMLHttpRequest.open() */
  var _xo=XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open=function(){
    var a=[].slice.call(arguments);a[1]=fix(a[1]);return _xo.apply(this,a);};

  /* WebSocket() */
  var _W=window.WebSocket;
  window.WebSocket=function(u,p){u=fix(u);return p!==void 0?new _W(u,p):new _W(u);};
  window.WebSocket.prototype=_W.prototype;
  window.WebSocket.CONNECTING=_W.CONNECTING;
  window.WebSocket.OPEN=_W.OPEN;
  window.WebSocket.CLOSING=_W.CLOSING;
  window.WebSocket.CLOSED=_W.CLOSED;

  /* history.pushState / replaceState – keep SPA routes inside Ingress scope */
  var _ps=history.pushState;var _rs=history.replaceState;
  history.pushState=function(s,t,u){return _ps.call(this,s,t,fix(u));};
  history.replaceState=function(s,t,u){return _rs.call(this,s,t,fix(u));};
})();
</script>
SHIMEOF

    # Use node (always present in the image) to inject shim after <head>
    cat > /tmp/inject-shim.js << 'JSEOF'
var fs = require('fs');
var shim = fs.readFileSync('/tmp/ingress-shim.html', 'utf8').trim();
var path = process.argv[2];
var html = fs.readFileSync(path, 'utf8');
// Insert shim right after <head> (with or without attributes)
html = html.replace(/<head([^>]*)>/, '<head$1>' + shim);
fs.writeFileSync(path, html);
JSEOF
    node /tmp/inject-shim.js "$TMP_HTML"
    rm -f /tmp/inject-shim.js /tmp/ingress-shim.html
    log "Ingress shim injected (fetch / XHR / WebSocket / pushState rewriter)"
  else
    log "Ingress shim already present, skipping injection"
  fi

  # Copy patched file back (Dockerfile makes dist writable; fallback chmod just in case)
  cp "$TMP_HTML" "$INDEX_HTML" 2>/dev/null || { chmod u+w "$INDEX_HTML" && cp "$TMP_HTML" "$INDEX_HTML"; }
  rm -f "$TMP_HTML"
  log "Ingress patches applied to index.html"
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
  log "JWT_SECRET set=$([ -n "$JWT_SECRET" ] && echo yes || echo no)"
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
