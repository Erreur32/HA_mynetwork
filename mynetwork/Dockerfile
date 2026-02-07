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

ENTRYPOINT []
CMD ["/run.sh"]
