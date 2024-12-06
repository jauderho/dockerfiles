FROM ghcr.io/jauderho/golang:1.23.4-alpine3.20@sha256:b9a03910400f9d9ca18918635d05e56f50fa319e63b08a3ea6d9774ea7f3928e AS build

WORKDIR /go/src/github.com/juanfont/headscale/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/juanfont/headscale/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/headscale.tar.gz \
	&& tar xzf /tmp/headscale.tar.gz --strip 1 -C /go/src/github.com/juanfont/headscale \
	&& go get -u github.com/jackc/pgx/v5 github.com/go-jose/go-jose/v3 google.golang.org/grpc google.golang.org/genproto google.golang.org/protobuf \
	&& go mod tidy \
	&& go build -o ./headscale -v -trimpath -ldflags="-s -w -X github.com/juanfont/headscale/cmd/headscale/cli.Version=${BUILD_VERSION}" ./cmd/headscale 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.21.0@sha256:f1c32703dfc24d994cb29a14dba612df8cd56ef5c4df8e443803d11cacadd150

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/headscale"
LABEL org.opencontainers.image.description="An open source, self-hosted implementation of the Tailscale coordination server."

RUN apk update \
	&& apk upgrade -a

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/juanfont/headscale/headscale /usr/local/bin/headscale
COPY --from=build /config /config

EXPOSE 8080/tcp

ENTRYPOINT ["/usr/local/bin/headscale"]
CMD ["help"]

