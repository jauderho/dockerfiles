FROM golang:1.21.1-alpine3.18@sha256:1c9cc949513477766da12bfa80541c4f24957323b0ee00630a6ff4ccf334b75b AS build

WORKDIR /go/src/github.com/slackhq/nebula/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/slackhq/nebula/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/nebula.tar.gz \
	&& tar xzf /tmp/nebula.tar.gz --strip 1 -C /go/src/github.com/slackhq/nebula \
	&& go build -o ./nebula -v -trimpath -ldflags="-s -w -X main.Build=${BUILD_VERSION}" ./cmd/nebula \
	&& go build -o ./nebula-cert -v -trimpath -ldflags="-s -w -X main.Build=${BUILD_VERSION}" ./cmd/nebula-cert

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.14

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/nebula"
LABEL org.opencontainers.image.description="nebula is a scalable overlay networking tool with a focus on performance, simplicity and security"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/slackhq/nebula/nebula /usr/local/bin/nebula
COPY --from=build /go/src/github.com/slackhq/nebula/nebula-cert /usr/local/bin/nebula-cert
COPY --from=build /config /config

CMD ["/usr/local/bin/nebula"]

