#!/usr/bin/env bash
set -e

ENV_FILE=".env"

# Load env vars into current shell
if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "❌ .env not found"
  exit 1
fi

# Pass EVERYTHING to tofu
exec tofu "$@"
