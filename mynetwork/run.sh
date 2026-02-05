#!/usr/bin/with-contenv bashio

echo "Starting MynetworK..."


export JWT_SECRET=$(bashio::config 'jwt_secret')
export FREEBOX_HOST=$(bashio::config 'freebox_host')


cd /app
./start.sh
