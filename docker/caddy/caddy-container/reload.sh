#!/usr/bin/env bash

CADDY_CONTAINER="caddy"

echo "🔹 fmt Caddyfile..."
docker exec -w /etc/caddy "$CADDY_CONTAINER" caddy fmt --overwrite /etc/caddy/Caddyfile

echo "🔄 caddy reload..."
docker compose restart "$CADDY_CONTAINER"

echo "✅ Caddy reload successfull!"
