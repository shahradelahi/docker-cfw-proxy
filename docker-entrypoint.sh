#!/bin/bash

set -e

if [ "${DEBUG}" == "true" ]; then
  set -x
fi

source /etc/cfw-proxy/internal/index.sh

GOST_CONFIG=/etc/gost/gost.conf
WGCF_CONFIG=/data/wgcf-profile.conf

if [ ! -f "${GOST_CONFIG}" ]; then
  log "notice" "Generating GOST config"
  dirname "$GOST_CONFIG"
  mkdir -p "$(dirname "${GOST_CONFIG}")"
  touch "${GOST_CONFIG}"
  generate_gost_config "${GOST_CONFIG}"
else
  log "notice" "Using existing GOST config"
fi

if [ ! -e "/data/wgcf-profile.conf" ]; then
  log "notice" "Registering "
  register_wgcf_config
fi

update_wgcf_config "${WGCF_CONFIG}"

sleep 1
echo -e "\n========================= GOST ========================="
cat "${GOST_CONFIG}"
echo -e "\n======================== wgcf ========================="
cat "${WGCF_CONFIG}"
echo -e "============================================================\n"
sleep 1

# Fix permissions
chmod 400 ${GOST_CONFIG}
chmod 400 "${GOST_CONFIG}"

wg-quick up ${WGCF_CONFIG}

_USERNAME=${PROXY_USERNAME:-awesome-username}
_PASSWORD=${PROXY_PASSWORD:-super-secret-password}

exec gost \
  -L "socks5://${_USERNAME}:${_PASSWORD}@:${SOCKS5_PORT:-1080}" \
  -L "http://${_USERNAME}:${_PASSWORD}@:${HTTP_PORT:-8080}" \
  -L "ss://$(lowercase "${SHADOWSOCKS_CIPHER:-AES-256-CFB}"):${_PASSWORD}@:${SHADOWSOCKS_PORT:-8338}"
