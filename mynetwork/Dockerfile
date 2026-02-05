ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64-base:latest
FROM ${BUILD_FROM}

# Installe Node.js + outils réseau
RUN apk add --no-cache \
    nodejs=22.11.0-r0 \
    npm \
    curl \
    iputils-ping \
    iproute2 \
    samba-common \
    nmap

# Copie fichiers MynetworK
COPY package*.json server/ dist/ tsconfig.json ./
COPY --from=ghcr.io/erreur32/mynetworK:latest /app/node_modules ./node_modules

WORKDIR /app

# Installe dépendances production
RUN npm ci --production --no-optional \
    && npm cache clean --force

# Permissions
RUN chmod +x /app/docker-entrypoint.sh || true
