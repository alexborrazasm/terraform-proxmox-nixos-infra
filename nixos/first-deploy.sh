#!/usr/bin/env bash
set -euo pipefail

# Check that SSH key argument was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_ssh_key>"
  exit 1
fi

ssh_key=$1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# List of hosts to iterate
hosts=("caddy" "worker1" "worker2" "worker3" "monitoring")

for host in "${hosts[@]}"; do
  # Assign IP based on host name
  case $host in
  "caddy") ip_suffix="10" ;;
  "worker1") ip_suffix="11" ;;
  "worker2") ip_suffix="12" ;;
  "worker3") ip_suffix="13" ;;
  "monitoring") ip_suffix="14" ;;
  esac

  echo "----------------------------------------------------"
  echo "Deploying $host at 10.60.60.$ip_suffix"
  echo "----------------------------------------------------"

  bash "${SCRIPT_DIR}/deploy-new-host.sh" "$host" "debian@10.60.60.$ip_suffix" "$ssh_key"
done
