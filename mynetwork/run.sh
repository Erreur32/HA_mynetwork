#!/usr/bin/with-contenv bashio

echo "Starting MynetworK..."

export JWT_SECRET=$(bashio::config 'jwt_secret')
export FREEBOX_HOST=$(bashio::config 'freebox_host')
export NODE_ENV=production
export PORT=3000

cd /app
exec npx tsx server/index.ts
