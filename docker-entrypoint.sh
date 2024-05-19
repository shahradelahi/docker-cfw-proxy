#!/bin/bash

set -e

if [ -n "$DEBUG" ]; then
  set -x
fi

source /etc/cfw-proxy/internal/index.sh

WGCF_CONFIG=/data/wgcf-account.toml
WG_CONFIG=/data/wgcf-profile.conf
update_wgcf_config "$WG_CONFIG"
chmod 400 "$WG_CONFIG"

sleep 1
echo -e "\n========================= WGCF ========================="
cat "$WGCF_CONFIG"
echo -e "\n====================== WireGuard ======================="
cat "$WG_CONFIG"
echo -e "========================================================\n"
sleep 1

wg-quick up "$WG_CONFIG"

_USERNAME=${PROXY_USERNAME:-awesome-username}
_PASSWORD=${PROXY_PASSWORD:-super-secret-password}

exec gost \
  -L "socks5://${_USERNAME}:${_PASSWORD}@:${SOCKS5_PORT:-1080}" \
  -L "http://${_USERNAME}:${_PASSWORD}@:${HTTP_PORT:-8080}" \
  -L "ss://$(lowercase "${SHADOWSOCKS_CIPHER:-AES-256-CFB}"):${_PASSWORD}@:${SHADOWSOCKS_PORT:-8338}"
