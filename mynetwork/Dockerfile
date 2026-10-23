# Base image is set here (build.yaml is deprecated; since Supervisor 2026.04 BUILD_FROM is
# no longer passed). Tag pinned to the upstream MynetworK release by scripts/update-version.sh.
ARG BUILD_FROM=ghcr.io/erreur32/mynetwork:0.13.7
FROM ${BUILD_FROM}

# Fail build if base image is missing app (e.g. wrong tag or incomplete image)
RUN test -f /app/server/index.ts && test -x /app/node_modules/.bin/tsx || (echo "FATAL: base image must have /app/server and /app/node_modules (use ghcr.io/erreur32/mynetwork:TAG from https://github.com/Erreur32/MynetworK)" && exit 1)

# Base image may set USER node; apk needs root
USER root
RUN apk add --no-cache jq

COPY run.sh /run.sh
RUN chmod +x /run.sh

# Make frontend dist writable by root so the Ingress shim can be injected at runtime.
# The upstream files belong to node (uid 1000) and the AppArmor profile grants no
# dac_override/fowner, so root could not rewrite them without this chown.
RUN chown -R 0:0 /app/dist && chmod -R u+w /app/dist

# Symlink /app/data → /data (Supervisor persistent volume).
# The upstream code writes to /app/data/ (OUI database, config, etc.) but in HA
# the image layer is read-only at runtime. The Supervisor mounts /data as writable.
# Must be done at build time because rm -rf /app/data fails on read-only layers at runtime.
# Original /app/data content is kept in /app/data_defaults; run.sh seeds /data from it.
RUN mkdir -p /app/data_defaults \
 && { cp -a /app/data/. /app/data_defaults/ 2>/dev/null || true; } \
 && rm -rf /app/data \
 && ln -s /data /app/data

ENTRYPOINT []
CMD ["/run.sh"]
