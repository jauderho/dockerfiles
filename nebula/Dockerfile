FROM golang:1.19.3-alpine3.16@sha256:dc4f4756a4fb91b6f496a958e11e00c0621130c8dfbb31ac0737b0229ad6ad9c AS build

WORKDIR /go/src/github.com/slackhq/nebula/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/slackhq/nebula/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
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

