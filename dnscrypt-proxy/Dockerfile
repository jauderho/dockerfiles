FROM golang:1.21.1-alpine3.18@sha256:96634e55b363cb93d39f78fb18aa64abc7f96d372c176660d7b8b6118939d97b AS build

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
	#&& go get -u golang.org/x/net \
	#&& go get -u golang.org/x/net golang.org/x/net/http2 github.com/quic-go/quic-go/internal/qtls \
	#&& go mod vendor \
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
