ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64-base:latest

# Instal Node.js (base HA n'a pas Node 22)
RUN apk add --no-cache nodejs npm su-exec curl iputils-ping iproute2 samba-common nmap

# Copy app MynetworK
COPY package*.json server/ dist/ tsconfig.json ./
COPY --from=ghcr.io/erreur32/mynetworK:latest /app/node_modules ./node_modules
WORKDIR /app
RUN npm ci --production --no-optional && npm cache clean --force && chmod +x docker-entrypoint.sh || true
