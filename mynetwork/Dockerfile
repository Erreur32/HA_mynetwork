ARG BUILD_FROM=ghcr.io/erreur32/mynetwork:0.5.6
FROM ${BUILD_FROM}

# jq pour lire /data/options.json (Supervisor)
RUN apk add --no-cache jq

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
