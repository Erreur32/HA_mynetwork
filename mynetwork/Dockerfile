ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64-base:latest
FROM ${BUILD_FROM}

# Node + outils réseau (du docker-compose)
RUN apk add --no-cache \
    nodejs>=18 \
    npm \
    curl \
    iputils-ping \
    iproute2 \
    samba-common \
    nmap

WORKDIR /app

# Copie app MynetworK
COPY package*.json ./
COPY server ./server
COPY dist ./dist
COPY tsconfig.json ./

RUN npm ci --production \
    && npm cache clean --force

EXPOSE 3000
