FROM ghcr.io/jauderho/golang:1.22.6-alpine3.20@sha256:1fd3c00db78749fbe841af819e4f52a5f11d23461c939f4615301c6fac412900 AS build

WORKDIR /go/src/github.com/DNSCrypt/dnscrypt-proxy/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/DNSCrypt/dnscrypt-proxy/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/dnscrypt-proxy.tar.gz \
	&& tar xzf /tmp/dnscrypt-proxy.tar.gz --strip 1 -C /go/src/github.com/DNSCrypt \
	#&& go get -u all \
	&& go mod download golang.org/x/sync \
	&& go get -u golang.org/x/sys golang.org/x/tools \
	&& go get -u google.golang.org/genproto \
	&& go get -u ./... \
	&& go mod tidy \
	&& go mod vendor \
	#&& go mod tidy \
	&& go build -v -trimpath -ldflags="-s -w"

WORKDIR /config

RUN cp -a /go/src/github.com/DNSCrypt/dnscrypt-proxy/example-* ./

COPY dnscrypt-proxy.toml ./


# ----------------------------------------------------------------------------


FROM scratch

# Credit for original Dockerfile goes to Kyle Harding <https://klutchell.dev>

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dnscrypt-proxy"
LABEL org.opencontainers.image.description="dnscrypt-proxy is a flexible DNS proxy, with support for encrypted DNS protocols"

COPY --from=build /etc/passwd /etc/group /etc/
COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/DNSCrypt/dnscrypt-proxy/dnscrypt-proxy /usr/local/bin/
COPY --from=build --chown=nobody:nogroup /config /config

# EXPOSE
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
USER nobody

ENTRYPOINT ["/usr/local/bin/dnscrypt-proxy"]
CMD ["-config", "/config/dnscrypt-proxy.toml"]
