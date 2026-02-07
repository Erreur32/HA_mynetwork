ARG BUILD_FROM=ghcr.io/erreur32/mynetwork:0.0.1
FROM ${BUILD_FROM}

# jq to read /app/data/options.json (Supervisor)
RUN apk add --no-cache jq

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
