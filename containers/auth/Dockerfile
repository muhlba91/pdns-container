ARG ALPINE_VERSION="latest"
ARG PDNS_DB_VERSION="4.3.1"
ARG PDNS_VERSION

FROM alpine:${ALPINE_VERSION}

ARG ALPINE_VERSION
ARG PDNS_VERSION
ARG PDNS_DB_VERSION
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

ENV PDNS_CONF_GSQLITE3_DATABASE="/var/lib/pdns/pdns.sqlite" \
  PDNS_GSQLITE3_VERSION=${PDNS_DB_VERSION}

RUN apk add --no-cache \
  bash \
  ca-certificates \
  git \
  wget \
  curl \
  s6-overlay \
  bind-tools \
  pdns=${PDNS_VERSION} \
  pdns-backend-sqlite3=${PDNS_VERSION} \
  pdns-doc=${PDNS_VERSION} \
  pdns-tools=${PDNS_VERSION} \
  && mkdir /etc/pdns/conf.d \
  && mkdir /data

COPY assets/s6-rc.d/ /etc/s6-overlay/s6-rc.d/
COPY assets/pdns-prepare-config.sh /bin/pdns-prepare-config
COPY assets/pdns-insert-data.sh /bin/pdns-insert-data
COPY assets/log-to-stdout.sh /bin/log-to-stdout
COPY assets/pdns.conf /etc/pdns/pdns.conf

EXPOSE 53/udp

ENTRYPOINT [ "/init" ]
