ARG BUILD_FROM=ghcr.io/erreur32/mynetwork:latest
FROM ${BUILD_FROM}

# Fail build if base image is missing app (e.g. wrong tag or incomplete image)
RUN test -f /app/server/index.ts && test -x /app/node_modules/.bin/tsx || (echo "FATAL: base image must have /app/server and /app/node_modules (use ghcr.io/erreur32/mynetwork:TAG from https://github.com/Erreur32/MynetworK)" && exit 1)

# Base image may set USER node; apk needs root
USER root
RUN apk add --no-cache jq

COPY run.sh /run.sh
RUN chmod +x /run.sh

# Make frontend dist writable so the Ingress shim can be injected at runtime
# (image layers are read-only; without this, sed/cp would fail on index.html)
RUN chmod -R u+w /app/dist 2>/dev/null || true

# Symlink /app/data → /data (Supervisor persistent volume).
# The upstream code writes to /app/data/ (OUI database, config, etc.) but in HA
# the image layer is read-only at runtime. The Supervisor mounts /data as writable.
# Must be done at build time because rm -rf /app/data fails on read-only layers at runtime.
RUN cp -rn /app/data/* /tmp/_appdata_backup/ 2>/dev/null || mkdir -p /tmp/_appdata_backup \
 && rm -rf /app/data \
 && ln -sf /data /app/data \
 && mv /tmp/_appdata_backup /app/data_defaults

ENTRYPOINT []
CMD ["/run.sh"]
