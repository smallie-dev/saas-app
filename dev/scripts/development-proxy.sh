#!/bin/bash

# Development proxy startup script
# Extracted from Taskfile for modular use

if ($(docker ps | grep -q development-proxy)); then
    echo "Development hosts proxy is already running."
    exit 0
fi

mkdir -p ~/.development-proxy/config || true
mkdir -p ~/.development-proxy/certs || true

echo "Starting development proxy..."
docker network create development-proxy > /dev/null 2>&1 || true

#MSYS_NO_PATHCONV will stop git bash form converting paths to windows paths
MSYS_NO_PATHCONV=1 docker run \
    --detach \
    --rm \
    --publish 80:80 \
    --publish 443:443 \
    --publish 10081:10081 \
    --volume //var/run/docker.sock:/var/run/docker.sock:ro \
    --volume "$HOME/.development-proxy/config:/var/config:ro" \
    --volume "$HOME/.development-proxy/certs:/var/certs:ro" \
    --name development-proxy \
    --network development-proxy \
    traefik:v2.11 \
    --api.insecure=true \
    --providers.docker=true \
    --providers.docker.exposedbydefault=false \
    --providers.file.directory=/var/config \
    --providers.file.watch=true \
    --entrypoints.web.address=:80 \
    --entrypoints.web-secure.address=:443 \
    --entrypoints.traefik.address=:10081 \
    > /dev/null && echo "Started."