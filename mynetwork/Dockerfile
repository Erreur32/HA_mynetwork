ARG BUILD_FROM
FROM $BUILD_FROM

# Install requirements for app
RUN apk add --no-cache \
    nodejs>=18 \
    npm \
    python3 \
    make \
    g++ \
    pkgconfig \
    sqlite-dev \
    curl \
    iputils-ping \
    iproute2 \
    samba-common \
    nmap

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev \
    && npm cache clean --force

COPY server ./server
COPY dist ./dist
COPY tsconfig.json ./

# Copy data for app
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
