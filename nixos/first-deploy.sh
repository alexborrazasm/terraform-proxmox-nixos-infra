#!/usr/bin/env bash

# Comprobamos que se ha pasado el argumento para la llave SSH
if [ -z "$1" ]; then
  echo "Uso: $0 <path_a_la_llave_ssh>"
  exit 1
fi

ssh_key=$1

# Lista de hosts a iterar
hosts=("caddy" "worker1" "worker2" "worker3" "monitoring")

for host in "${hosts[@]}"; do
  # Asignamos la IP según el nombre
  case $host in
  "caddy") ip_suffix="10" ;;
  "worker1") ip_suffix="11" ;;
  "worker2") ip_suffix="12" ;;
  "worker3") ip_suffix="13" ;;
  "monitoring") ip_suffix="14" ;;
  esac

  echo "----------------------------------------------------"
  echo "🚀 Desplegando $host en 10.60.60.$ip_suffix"
  echo "----------------------------------------------------"

  nix run github:nix-community/nixos-anywhere -- \
    --flake ".#$host" \
    "template@10.60.60.$ip_suffix" \
    -i "$ssh_key"
done
