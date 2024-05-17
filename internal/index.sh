#!/bin/bash

source "/etc/cfw-proxy/internal/string"
source "/etc/cfw-proxy/internal/wgcf"

log() {
  local LEVEL=${1}
  local MESSAGE=${2}
  # Feb 20 16:48:35 UTC [notice] message
  echo -e "$(date +"%b %d %H:%M:%S %Z") [${LEVEL}] ${MESSAGE}"
}

generate_gost_config() {
  _USERNAME=${PROXY_USERNAME:-awesome-username}
  _PASSWORD=${PROXY_PASSWORD:-super-secret-password}
  tee "$1" &> /dev/null << EOF
services:
- name: http
  addr: ":${HTTP_PORT:-8080}"
  handler:
    type: http
    auth:
      username: ${_USERNAME}
      password: "${_PASSWORD}"
  listener:
    type: tcp
- name: socks
  addr: ":${SOCKS5_PORT:-1080}"
  handler:
    type: socks
    udp: true
    bind: true
    auth:
      username: ${_USERNAME}
      password: "${_PASSWORD}"
  listener:
    type: tcp
- name: shadowsocks
  addr: ":${SHADOWSOCKS_PORT:-8338}"
  handler:
    type: ss
    auth:
      username: ${SHADOWSOCKS_CIPHER:-AES-256-CFB}
      password: "${_PASSWORD}"
  listener:
    type: tcp
EOF
}
