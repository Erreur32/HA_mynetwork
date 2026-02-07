ARG BUILD_FROM=ghcr.io/erreur32/mynetwork:0.1.0
FROM ${BUILD_FROM}

# Fail build if base image is missing app (e.g. wrong tag or incomplete image)
RUN test -f /app/server/index.ts && test -x /app/node_modules/.bin/tsx || (echo "FATAL: base image must have /app/server and /app/node_modules (use ghcr.io/erreur32/mynetwork:TAG from https://github.com/Erreur32/MynetworK)" && exit 1)

# Base image may set USER node; apk needs root
USER root
RUN apk add --no-cache jq

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
