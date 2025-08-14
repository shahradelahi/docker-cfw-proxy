ARG ALPINE_VERSION=3.22
ARG WGCF_VERSION=2.2.28
ARG GOST_VERSION=3.2.4

FROM --platform=${BUILDPLATFORM} gogost/gost:${GOST_VERSION} AS gost
FROM --platform=${BUILDPLATFORM} crazymax/alpine-s6:${ALPINE_VERSION} AS alpine
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >/etc/timezone
RUN apk update \
 && apk add -U --no-cache \
  iptables openresolv \
  bash curl \
  wireguard-tools \
  fping \
 && rm -rf /var/cache/apk/*

FROM golang:alpine AS wgcf
ARG WGCF_VERSION
WORKDIR /app
RUN apk add --no-cache make git \
 && git clone https://github.com/ViRb3/wgcf.git \
 && cd wgcf \
 && git checkout --detach "v$WGCF_VERSION" \
 && go mod tidy \
 && GO111MODULE=on CGO_ENABLED=0 go build -v -ldflags '-w -s -buildid=' -tags '' -trimpath \
 && mv wgcf /usr/local/bin/ \
 && chmod +x /usr/local/bin/wgcf \
 && cd - \
 && rm -rf wgcf \
 && rm -rf /var/cache/apk/*

FROM alpine
COPY --from=wgcf /usr/local/bin/wgcf /usr/local/bin/wgcf
COPY --from=gost /bin/gost /usr/local/bin/gost

VOLUME ["/data", "/lib/modules"]

HEALTHCHECK --interval=60s --timeout=5s --start-period=20s --retries=3 \
 CMD curl -s https://www.cloudflare.com/cdn-cgi/trace/ | grep -qE 'warp=(on|plus)' || exit 1

COPY rootfs /