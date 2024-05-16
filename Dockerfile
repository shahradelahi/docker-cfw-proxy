ARG ALPINE_VERSION=3.19
ARG WGCF_VERSION=2.2.22
ARG GOST_VERSION=3.0.0-rc10

FROM --platform=${BUILDPLATFORM} gogost/gost:${GOST_VERSION} AS gost
FROM --platform=${BUILDPLATFORM} alpine:${ALPINE_VERSION} as alpine

FROM alpine as base
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apk update \
  && apk upgrade \
  && apk add -U --no-cache \
    iproute2 iptables net-tools \
    bash curl \
    wireguard-tools \
  && rm -rf /var/cache/apk/*
COPY internal /etc/cfw-proxy/internal
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

FROM alpine as wgcf
ARG TARGETARCH
ARG WGCF_VERSION
RUN <<EOT
set -ex
case "$(arch)" in
  x86_64 | amd64) _ARCH="amd64" ;;
  aarch64 | arm64) _ARCH="arm64" ;;
  armv7l | armv7) _ARCH="armv7" ;;
  mips64le) _ARCH="mips64le_softfloat" ;;
  386 | s390x)
    _ARCH="$TARGETARCH"
    ;;
  *)
    echo "Unsupported architecture. $(arch)"
    exit 1
    ;;
esac
export DOWNLOAD_URL="https://github.com/ViRb3/wgcf/releases/download/v${WGCF_VERSION}/wgcf_${WGCF_VERSION}_linux_${_ARCH}"
wget -qO /usr/local/bin/wgcf "$DOWNLOAD_URL"
chmod +x /usr/local/bin/wgcf
EOT

FROM --platform=${BUILDPLATFORM} base
LABEL maintainer="Shahrad Elahi <https://github.com/shahradelahi>"
LABEL org.opencontainers.image.vendor=shahradelahi
LABEL org.opencontainers.image.title="CloudFlare WARP Proxy"
LABEL org.opencontainers.image.description="A Lightweight docker image for connecting to CloudFlare WARP trough $(Socks), $(HTTP) and $(Shadowsocks) proxy protocols"
LABEL org.opencontainers.image.source="https://github.com/shahradelahi/docker-cfw-proxy"
LABEL org.opencontainers.image.url="https://github.com/users/shahradelahi/packages/container/package/docker-cfw-proxy"
LABEL org.opencontainers.image.base.name="ghcr.io/shahradelahi/cfw-proxy"
COPY --from=wgcf /usr/local/bin/wgcf /usr/local/bin/wgcf
COPY --from=gost /bin/gost /usr/local/bin/gost
VOLUME ["/data", "/lib/modules"]
HEALTHCHECK --interval=60s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -s https://www.cloudflare.com/cdn-cgi/trace/ | grep -qE 'warp=(on|plus)' || exit 1
ENTRYPOINT ["/entrypoint.sh"]
CMD ["gost", "-C", "/etc/gost/gost.conf"]
