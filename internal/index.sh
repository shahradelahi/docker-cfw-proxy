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
  tee "$1" &> /dev/null << EOF
services:
- name: http
  addr: ":8080"
  handler:
    type: http
    auth:
      username: ${PROXY_USERNAME:-awesome-username}
      password: "${PROXY_PASSWORD:-super-secret-password}"
  listener:
    type: tcp
- name: socks
  addr: ":1080"
  handler:
    type: socks
    udp: true
    bind: true
    auth:
      username: ${PROXY_USERNAME:-awesome-username}
      password: "${PROXY_PASSWORD:-super-secret-password}"
  listener:
    type: tcp
- name: shadowsocks
  addr: ":8338"
  handler:
    type: ss
    auth:
      username: ${SS_ALGO:-CHACHA20_POLY1305}
      password: "${PROXY_PASSWORD:-super-secret-password}"
  listener:
    type: tcp
EOF
}
