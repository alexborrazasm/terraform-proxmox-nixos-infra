#!/usr/bin/env bash
set -euo pipefail

HOST="$1"
TARGET="$2"
SSH_KEY="$3"

KEYDIR="./hostkeys/${HOST}"

if [ ! -f "${KEYDIR}/etc/ssh/ssh_host_ed25519_key" ]; then
  echo "Host key does not exist for ${HOST}. Generating..."
  mkdir -p "${KEYDIR}/etc/ssh"
  ssh-keygen -t ed25519 \
    -f "${KEYDIR}/etc/ssh/ssh_host_ed25519_key" \
    -N "" -C "root@${HOST}"
  chmod 600 "${KEYDIR}/etc/ssh/ssh_host_ed25519_key"

  echo ""
  echo "Add this pubkey to secrets.nix as '${HOST}':"
  cat "${KEYDIR}/etc/ssh/ssh_host_ed25519_key.pub"
  echo ""
  echo "Then run: agenix -r"
  echo "And re-run this script."
  exit 1
fi

nix run github:nix-community/nixos-anywhere -- \
  --flake ".#${HOST}" \
  --extra-files "${KEYDIR}" \
  --ssh-option "IdentityFile=${SSH_KEY}" \
  "${TARGET}"
