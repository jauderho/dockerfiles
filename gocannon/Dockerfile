FROM ghcr.io/jauderho/golang:1.24.3-alpine3.21@sha256:4b6d42f444193a96e296691ac8ddf0902aa28bddefb58a366d03b299e7ebc1d3 AS build

WORKDIR /go/src/github.com/kffl/gocannon/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/kffl/gocannon/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/gocannon.tar.gz \
	&& tar xzf /tmp/gocannon.tar.gz --strip 1 -C /go/src/github.com/kffl/gocannon \
	&& go build -v -trimpath -ldflags="-s -w" . 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.14

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/gocannon"
LABEL org.opencontainers.image.description="Gocannon is a lightweight HTTP benchmarking tool"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/kffl/gocannon/gocannon /usr/local/bin/gocannon
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/gocannon"]
CMD ["--help"]

