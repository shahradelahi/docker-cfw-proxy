ARG ALPINE_VERSION=3.19
ARG WGCF_VERSION=2.2.22
ARG GOST_VERSION=3.0.0-rc10

FROM --platform=${BUILDPLATFORM} gogost/gost:${GOST_VERSION} AS gost
FROM --platform=${BUILDPLATFORM} alpine:${ALPINE_VERSION} as alpine
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apk update \
  && apk upgrade \
  && rm -rf /var/cache/apk/*

FROM alpine as base
RUN apk add -U --no-cache \
  iptables fping \
  bash curl \
  wireguard-tools \
  && rm -rf /var/cache/apk/*
COPY internal /etc/cfw-proxy/internal
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

FROM alpine as wgcf
ARG TARGETARCH
ARG WGCF_VERSION
COPY internal/install_wgcf /install_wgcf
RUN chmod +x /install_wgcf \
  && /install_wgcf \
  && rm -f /install_wgcf

FROM base
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
