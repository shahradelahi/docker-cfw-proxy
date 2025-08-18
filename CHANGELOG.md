# docker-cfw-proxy

## 2.0.1

### Patch Changes

- 10ea365: Using `xx` dockerfile cross-compilation helpers

## 2.0.0

### Major Changes

- ecbd7a5: Default proxy config is now `noauth` and only `Socks5` and `HTTP` is available.
- 6b6eef1: Default `Shadowsocks` proxy is removed and instruction for custom proxy config added to `README.md` file.

### Minor Changes

- 328220a: feat: Add `KEEP_ALIVE` option for WireGuard interface

## 1.2.1

### Patch Changes

- b66ab0a: fix: Updated dependencies

## 1.2.0

### Minor Changes

- f21610c: feat: using `s6-overlay`

### Patch Changes

- f21610c: fix: issue when ipv6 is not available

## 1.1.1

### Patch Changes

- 5d8ee40: fix: update dependencies

## 1.1.0

### Minor Changes

- dad9236: feat: add `DNS_PROFILE` env for changing the DNS profile
- b3e3405: feat: automatically detect and apply fastest endpoint

### Patch Changes

- 0f5f2df: feat: ability to modify `MTU` and `DNS`
