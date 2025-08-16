# docker-cfw-proxy

[![CI](https://github.com/shahradelahi/docker-cfw-proxy/actions/workflows/ci.yml/badge.svg)](https://github.com/shahradelahi/docker-cfw-proxy/actions/workflows/ci.yml)
[![GPL-3.0 Licensed](https://img.shields.io/badge/License-GPL3.0-blue.svg?style=flat)](https://opensource.org/licenses/GPL-3.0)
[![Code Size](https://img.shields.io/github/languages/code-size/shahradelahi/docker-cfw-proxy)](https://github.com/shahradelahi/docker-cfw-proxy)
[![Open Issues](https://img.shields.io/github/issues/shahradelahi/docker-cfw-proxy)](https://github.com/shahradelahi/docker-cfw-proxy/issues)
[![Visitors](https://api.visitorbadge.io/api/visitors?path=https%3A%2F%2Fgithub.com%2Fshahradelahi%2Fdocker-cfw-proxy&countColor=%23263759&style=flat&labelStyle=upper)](https://visitorbadge.io/status?path=https%3A%2F%2Fgithub.com%2Fshahradelahi%2Fdocker-cfw-proxy)

> A Lightweight docker image for connecting to CloudFlare WARP trough `Socks`, `HTTP` and `Shadowsocks` proxy protocols

---

- [Features](#features)
- [Build locally](#build-locally)
- [Image](#image)
- [Environment variables](#environment-variables)
- [Ports](#ports)
- [Usage](#usage)
  - [Docker Compose](#docker-compose)
  - [Command line](#command-line)
- [WARP+ license](#warp-license)
- [Upgrade](#upgrade)
- [Contributing](#contributing)
- [License](#license)

## Features

- Support `Socks5`, `HTTP` and `Shadowsocks` proxy protocols
- Apply license key to use existing `Warp+` subscription
- Multi-platform image

## Build locally

```shell
git clone https://github.com/shahradelahi/docker-cfw-proxy
cd docker-cfw-proxy

# Build image and output to docker (default)
docker buildx bake

# Build multi-platform image
docker buildx bake image-all
```

## Image

| Registry                                                                                                | Image                            |
| ------------------------------------------------------------------------------------------------------- | -------------------------------- |
| [Docker Hub](https://hub.docker.com/r/shahradel/cfw-proxy/)                                             | `shahradel/cfw-proxy`            |
| [GitHub Container Registry](https://github.com/users/shahradelahi/packages/container/package/cfw-proxy) | `ghcr.io/shahradelahi/cfw-proxy` |

Following platforms for this image are available:

```
$ docker run --rm mplatform/mquery shahradel/cfw-proxy:latest
Image: shahradel/cfw-proxy:latest
 * Manifest List: Yes (Image type: application/vnd.oci.image.index.v1+json)
 * Supported platforms:
   - linux/amd64
   - linux/arm/v6
   - linux/arm/v7
   - linux/arm64
   - linux/386
   - linux/s390x
```

## Environment variables

- `TZ`: Timezone assigned to the container (default `UTC`)
- `PROXY_USERNAME`: The username of `Socks5` and `HTTP` proxy (default `awesome-username`)
- `PROXY_PASSWORD`: The password of all proxy protocols (default `super-secret-password`)
- `SOCKS5_PORT`: The port of `Socks5` proxy (default `1080`)
- `HTTP_PORT`: The port of `HTTP` proxy (default `8080`)
- `SHADOWSOCKS_PORT`: The port of `Shadowsocks` proxy (default `8338`)
- `SHADOWSOCKS_CIPHER`: The cipher of `Shadowsocks` proxy (default `CHACHA20-IETF-POLY1305`)
- `WGCF_ENDPOINT`: The `endpoint` of the WARP endpoint (default `engage.cloudflareclient.com:2408`)
- `WGCF_ENDPOINT_CIDR`: The `cidr` of the WARP endpoint (default `162.159.192.0/24`)
- `WGCF_ENDPOINT_PORT`: WARP endpoint port (default `2408`)
- `FAST_ENDPOINT`: Enables the feature for searching for endpoint with the lowest latency
- `WGCF_LICENSE_KEY`: The license key of CloudFlare WARP+
- `DNS_PROFILE`: Presets of CloudFlare DNS servers (default `default`)
- `DNS`: The `dns` of the WireGuard interface (default `1.1.1.1, 1.0.0.1, 2606:4700:4700::1111, 2606:4700:4700::1001`)
- `MTU`: The `mtu` of the WireGuard interface (default `1280`)

> 💡 `WGCF_LICENSE_KEY` is optional and to obtain it follow guides in [`WARP+ license`](#warp-license) section.

## Ports

- `1080`: `Socks5` proxy
- `8080`: `HTTP` proxy
- `8338`: `Shadowsocks` proxy

## Usage

### Docker Compose

Docker compose is the recommended way to run this image. You can use the following
[docker compose template](docker-compose.yml), then run the container:

```bash
docker compose up -d
docker compose logs -f
```

### Command line

You can also use the following minimal command:

```bash
$ docker run -d \
  --name warp \
  -p 1080:1080 -p 8080:8080 -p 8338:8338 \
  -e "PROXY_USERNAME=awesome-username" \
  -e "PROXY_PASSWORD=super-secret-password" \
  -e "SHADOWSOCKS_CIPHER=CHACHA20-IETF-POLY1305" \
  --privileged \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  --sysctl net.ipv4.ip_forward=1 \
  --sysctl net.ipv4.conf.all.src_valid_mark=1 \
  --sysctl net.ipv6.conf.all.disable_ipv6=0 \
  shahradel/cfw-proxy
```

## Upgrade

Recreate the container whenever I push an update:

```bash
docker compose pull
docker compose up -d
```

## WARP+ license

If you have an existing Warp+ subscription, for example on your phone, you can bind the account generated by this tool to your phone's account, sharing its Warp+ status. Please note that there is a limit of 5 maximum devices linked at a time. You can remove linked devices from the 1.1.1.1 app on your phone.

> [!CAUTION]
> Only subscriptions purchased directly from the official 1.1.1.1 app are supported. Keys obtained by any other means, including referrals, will not work and will not be supported.

First, get your Warp+ account license key. To view it on Android:

1. Open the `1.1.1.1` app
2. Click on the hamburger menu button in the top-right corner
3. Navigate to: `Account` > `Key`

Finally, copy and paste the license key into the `WGCF_LICENSE_KEY` environment variable and restart the container.

## Contributing

Want to contribute? Awesome! To show your support is to star the project, or to raise issues
on [GitHub](https://github.com/shahradelahi/docker-cfw-proxy).

Thanks again for your support, it is much appreciated! 🙏

## Credits

- [WireGuard](https://www.wireguard.com/)
- [WGCF](https://github.com/ViRb3/wgcf) CLI for Cloudflare Warp (Unofficial)

## License

[GPL-3.0](/LICENSE)

## Notice of Non-Affiliation and Disclaimer

We are not affiliated, associated, authorized, endorsed by, or officially connected in any way with Cloudflare or any of its subsidiaries or affiliates. The official Cloudflare website is https://www.cloudflare.com.

The names _Cloudflare Warp_ and _Cloudflare_, as well as any related names, marks, emblems, and images, are registered trademarks of their respective owners.
