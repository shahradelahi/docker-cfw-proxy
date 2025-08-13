ARG ALPINE_VERSION=3.21
ARG WGCF_VERSION=2.2.25
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

FROM alpine AS wgcf
ARG WGCF_VERSION
RUN <<EOT
  case "$(arch)" in
    x86_64 | amd64) _ARCH="amd64" ;;
    aarch64 | arm64) _ARCH="arm64" ;;
    armv7l | armv7) _ARCH="armv7" ;;
    mips64le) _ARCH="mips64le_softfloat" ;;
    s390x) _ARCH="s390x" ;;
    386) _ARCH="386" ;;
    *)
      echo "Unsupported architecture. $(arch)"
      exit 1
      ;;
  esac
  DOWNLOAD_URL="https://github.com/ViRb3/wgcf/releases/download/v${WGCF_VERSION}/wgcf_${WGCF_VERSION}_linux_${_ARCH}"
  wget -qO /usr/local/bin/wgcf "$DOWNLOAD_URL"
  chmod +x /usr/local/bin/wgcf
EOT

FROM alpine
COPY --from=wgcf /usr/local/bin/wgcf /usr/local/bin/wgcf
COPY --from=gost /bin/gost /usr/local/bin/gost

VOLUME ["/data", "/lib/modules"]

HEALTHCHECK --interval=60s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -s https://www.cloudflare.com/cdn-cgi/trace/ | grep -qE 'warp=(on|plus)' || exit 1

COPY rootfs /
