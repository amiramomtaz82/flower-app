#!/usr/bin/env bash
#
# setup.sh — Automated Full Microservices Backend Launcher for Flutter (Git Bash / Linux / macOS)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.prod.yml"

log() { echo -e "\033[1;34m[setup_backend]\033[0m $*"; }
success() { echo -e "\033[1;32m[setup_backend]\033[0m $*"; }
die() { echo -e "\033[1;31m[setup_backend] ERROR:\033[0m $*" >&2; exit 1; }

command -v docker >/dev/null 2>&1 || die "docker is not installed or not on PATH"

RECREATE=false
POSITIONAL=()
for arg in "$@"; do
  case "$arg" in
    --recreate) RECREATE=true ;;
    *) POSITIONAL+=("$arg") ;;
  esac
done

ENV_VAR_NAME="${POSITIONAL[0]:-BASE_URL}"

if [[ ! -f "$ENV_FILE" ]]; then
  log "Creating default .env at $ENV_FILE"
  touch "$ENV_FILE"
fi

if $RECREATE; then
  log "Pulling & Recreating containers (--recreate)..."
  docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" pull || true
  docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d --force-recreate
else
  log "Starting Flower E-Commerce Microservices backend..."
  docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d
fi

get_host_ip() {
  case "$(uname -s)" in
    Darwin)
      for iface in en0 en1 en2; do
        ip="$(ipconfig getifaddr "$iface" 2>/dev/null || true)"
        [[ -n "$ip" ]] && { echo "$ip"; return; }
      done
      ;;
    Linux)
      ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
      if [[ -z "$ip" ]]; then
        ip="$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}')"
      fi
      [[ -n "$ip" ]] && { echo "$ip"; return; }
      ;;
    MINGW*|MSYS*|CYGWIN*)
      ip="$(ipconfig.exe 2>/dev/null | grep -i "IPv4 Address" | head -n1 | awk -F': ' '{print $2}' | tr -d '\r')"
      [[ -n "$ip" ]] && { echo "$ip"; return; }
      ;;
    *)
      ;;
  esac
  echo "127.0.0.1"
}

DEVICE_IP="$(get_host_ip)"
HOST_PORT="8080"
BASE_URL="http://${DEVICE_IP}:${HOST_PORT}"

TMP_FILE="$(mktemp)"
awk -v key="$ENV_VAR_NAME" -v val="$BASE_URL" '
  BEGIN { FS=OFS="="; found=0 }
  $1 == key { print key "=" val; found=1; next }
  { print }
  END { if (!found) print key "=" val }
' "$ENV_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$ENV_FILE"

success "Wrote ${ENV_VAR_NAME}=${BASE_URL} to $ENV_FILE"
echo ""
echo -e "\033[1;36m=================================================================\033[0m"
echo -e "\033[1;32m  Flower E-Commerce Backend Running Successfully! \033[0m"
echo -e "\033[1;36m=================================================================\033[0m"
echo -e "  📌 API Gateway Base URL:    \033[1;33m${BASE_URL}\033[0m"
echo -e "  🏥 Gateway Identity Health: \033[1;33m${BASE_URL}/Identity\033[0m"
echo -e "  🏥 Gateway Catalog Health:  \033[1;33m${BASE_URL}/Catalog\033[0m"
echo -e "  🏥 Gateway Cart Health:     \033[1;33m${BASE_URL}/Cart\033[0m"
echo -e "  🏥 Gateway Order Health:    \033[1;33m${BASE_URL}/Order\033[0m"
echo -e "  🏥 Gateway Payment Health:  \033[1;33m${BASE_URL}/Payment\033[0m"
echo -e "  🏥 Gateway Address Health:  \033[1;33m${BASE_URL}/Address\033[0m"
echo -e "-----------------------------------------------------------------"
echo -e "  📖 Direct Microservice Swagger UI Endpoints:"
echo -e "  Swagger Identity API: \033[1;36mhttp://localhost:5022/swagger\033[0m"
echo -e "  Swagger Catalog API:  \033[1;36mhttp://localhost:5129/swagger\033[0m"
echo -e "  Swagger Cart API:     \033[1;36mhttp://localhost:5292/swagger\033[0m"
echo -e "  Swagger Order API:    \033[1;36mhttp://localhost:5109/swagger\033[0m"
echo -e "  Swagger Payment API:  \033[1;36mhttp://localhost:5260/swagger\033[0m"
echo -e "  Swagger Address API:  \033[1;36mhttp://localhost:5272/swagger\033[0m"
echo -e "\033[1;36m=================================================================\033[0m"