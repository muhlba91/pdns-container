ARG ALPINE_VERSION="latest"
ARG PDNS_VERSION

FROM alpine:${ALPINE_VERSION}

ARG ALPINE_VERSION
ARG PDNS_VERSION
ARG CI_COMMIT_TIMESTAMP
ARG CI_COMMIT_SHA
ARG CI_COMMIT_TAG

LABEL org.opencontainers.image.authors="Daniel Muehlbachler-Pietrzykowski <daniel.muehlbachler@niftyside.com>"
LABEL org.opencontainers.image.vendor="Daniel Muehlbachler-Pietrzykowski"
LABEL org.opencontainers.image.source="https://github.com/muhlba91/pdns-container"
LABEL org.opencontainers.image.created="${CI_COMMIT_TIMESTAMP}"
LABEL org.opencontainers.image.title="pdns-auth"
LABEL org.opencontainers.image.description="PowerDNS (PDNS) Authoritative Server"
LABEL org.opencontainers.image.base.name "alpine:${ALPINE_VERSION}"
LABEL org.opencontainers.image.revision="${CI_COMMIT_SHA}"
LABEL org.opencontainers.image.version="${PDNS_VERSION}-${CI_COMMIT_TAG}"

RUN apk add --no-cache \
  bash \
  ca-certificates \
  git \
  wget \
  curl \
  s6-overlay \
  bind-tools \
  pdns-recursor=${PDNS_VERSION} \
  pdns-recursor-doc=${PDNS_VERSION} \
  && mkdir /etc/pdns/conf.d

COPY assets/s6-rc.d/ /etc/s6-overlay/s6-rc.d/
COPY assets/log-to-stdout.sh /bin/log-to-stdout
COPY assets/forward_zones.conf /etc/pdns/forward_zones.conf
COPY assets/recursor.conf /etc/pdns/recursor.conf

EXPOSE 53/udp

ENTRYPOINT [ "/init" ]
