#!/usr/bin/with-contenv bashio

echo "=== MynetworK Starting ==="

# Config HA
export JWT_SECRET=$(bashio::config 'jwt_secret')
export FREEBOX_HOST=$(bashio::config 'freebox_host')
export NODE_ENV=production
export PORT=3000
export HOST_IP=$(bashio::host_ip)  # HA host IP

cd /app

# Exec app (comme CMD original)
exec npx tsx server/index.ts
