FROM ghcr.io/hassio-addons/base:16.0.0

RUN apk add --no-cache bash curl

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
