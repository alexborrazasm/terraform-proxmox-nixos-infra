#!/usr/bin/env bash
set -euo pipefail

if [ "${#}" -lt 3 ]; then
  echo "Usage: $0 <host> <target> <ssh_key>"
  exit 1
fi

HOST="$1"
TARGET="$2"
SSH_KEY="$3"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYDIR="${SCRIPT_DIR}/hostkeys/${HOST}"

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
  --flake "${SCRIPT_DIR}#${HOST}" \
  --extra-files "${KEYDIR}" \
  --ssh-option "IdentityFile=${SSH_KEY}" \
  "${TARGET}"
