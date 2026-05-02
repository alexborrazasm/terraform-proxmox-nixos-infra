#!/usr/bin/env bash
set -euo pipefail

# --- Load .env ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ENV_FILE:-$SCRIPT_DIR/.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "✗ $ENV_FILE not found (copy it from .env.dist)" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

: "${GRAFANA_URL:?Missing GRAFANA_URL in .env}"
: "${GRAFANA_USER:?Missing GRAFANA_USER in .env}"
: "${GRAFANA_PASSWORD:?Missing GRAFANA_PASSWORD in .env}"

GRAFANA_AUTH="${GRAFANA_USER}:${GRAFANA_PASSWORD}"

# --- Config (with defaults if not set in .env) ---
DASHBOARD_SRC="${DASHBOARD_SRC:-dashboard.json}"
DASHBOARD_NAME="${DASHBOARD_NAME:-main-dashboard}"
NAMESPACE="${NAMESPACE:-default}"
OLD_DS_UID="${OLD_DS_UID:-bfkdgu0nr13pcb}"

# --- Colors ---
B="\033[1m"; DIM="\033[2m"; G="\033[32m"; Y="\033[33m"; R="\033[31m"; C="\033[36m"; N="\033[0m"

# --- Temp files with auto-cleanup ---
PATCHED=$(mktemp -t dashboard-patched.XXXXXX.json)
FIXED=$(mktemp -t dashboard-fixed.XXXXXX.json)
RESP=$(mktemp -t grafana-resp.XXXXXX.json)
trap 'rm -f "$PATCHED" "$FIXED" "$RESP"' EXIT

echo -e "${B}${C}▶ Importing dashboard to Grafana${N}"
echo -e "${DIM}  ${GRAFANA_URL} → ${NAMESPACE}/${DASHBOARD_NAME}${N}"
echo

# --- 1. k8s-style wrapper ---
echo -e "${B}[1/4]${N} Building payload..."
jq --arg name "$DASHBOARD_NAME" '{
  kind: .kind,
  apiVersion: .apiVersion,
  metadata: {name: $name},
  spec: (. | del(.kind, .apiVersion))
}' "$DASHBOARD_SRC" > "$PATCHED"

# --- 2. Real Prometheus datasource UID ---
echo -e "${B}[2/4]${N} Resolving Prometheus datasource..."
REAL_UID=$(curl -fsS -u "$GRAFANA_AUTH" "$GRAFANA_URL/api/datasources" \
  | jq -r '.[] | select(.type=="prometheus") | .uid')

if [[ -z "$REAL_UID" ]]; then
  echo -e "      ${R}✗ No Prometheus datasource found${N}"
  exit 1
fi
echo -e "      ${G}✓${N} UID = ${Y}${REAL_UID}${N}"

# --- 3. Replace UID ---
echo -e "${B}[3/4]${N} Replacing old UID..."
sed "s/${OLD_DS_UID}/${REAL_UID}/g" "$PATCHED" > "$FIXED"
echo -e "      ${G}✓${N} ${DIM}${OLD_DS_UID} → ${REAL_UID}${N}"

# --- 4. PUT to v2 endpoint ---
echo -e "${B}[4/4]${N} Sending to Grafana..."
HTTP_CODE=$(curl -sS -o "$RESP" -w "%{http_code}" \
  -X PUT "$GRAFANA_URL/apis/dashboard.grafana.app/v2/namespaces/$NAMESPACE/dashboards/$DASHBOARD_NAME" \
  -H "Content-Type: application/json" \
  -u "$GRAFANA_AUTH" \
  -d @"$FIXED")

echo
if [[ "$HTTP_CODE" =~ ^2 ]]; then
  echo -e "${G}${B}✔ Dashboard '${DASHBOARD_NAME}' imported successfully${N} ${DIM}(HTTP ${HTTP_CODE})${N}"
else
  echo -e "${R}${B}✗ Import failed${N} ${DIM}(HTTP ${HTTP_CODE})${N}"
  echo -e "${DIM}--- Grafana response ---${N}"
  jq . "$RESP" 2>/dev/null || cat "$RESP"
  exit 1
fi