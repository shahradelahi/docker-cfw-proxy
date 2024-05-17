#!/bin/bash

set -e

if [ "${DEBUG}" == "true" ]; then
  set -x
fi

source /etc/cfw-proxy/internal/index.sh

WGCF_CONFIG=/data/wgcf-profile.conf

if [ ! -e "$WGCF_CONFIG" ]; then
  log "notice" "Registering CloudFlare WARP account"
  register_wgcf_config
fi

update_wgcf_config "$WGCF_CONFIG"
# Fix permissions
chmod 400 "$WGCF_CONFIG"

sleep 1
echo -e "\n======================== wgcf ========================="
cat "$WGCF_CONFIG"
echo -e "============================================================\n"
sleep 1

wg-quick up "$WGCF_CONFIG"

_USERNAME=${PROXY_USERNAME:-awesome-username}
_PASSWORD=${PROXY_PASSWORD:-super-secret-password}

exec gost \
  -L "socks5://${_USERNAME}:${_PASSWORD}@:${SOCKS5_PORT:-1080}" \
  -L "http://${_USERNAME}:${_PASSWORD}@:${HTTP_PORT:-8080}" \
  -L "ss://$(lowercase "${SHADOWSOCKS_CIPHER:-AES-256-CFB}"):${_PASSWORD}@:${SHADOWSOCKS_PORT:-8338}"
