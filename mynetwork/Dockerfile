ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64-base:latest
FROM ${BUILD_FROM}

# Node.js 22 + outils réseau
RUN apk add --no-cache \
    nodejs=22.11.0-r0 \
    npm \
    curl \
    iputils-ping \
    iproute2 \
    samba-common \
    nmap

WORKDIR /app

# Copie TOUS fichiers MynetworK (commit vos server/, dist/, package.json)
COPY package*.json ./
COPY server/ ./server/
COPY dist/ ./dist/
COPY tsconfig.json ./

# Installe dépendances (better-sqlite3 compile)
RUN npm ci --production --no-optional \
    && npm cache clean --force

EXPOSE 3000
