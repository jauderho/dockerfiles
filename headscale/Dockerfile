FROM ghcr.io/jauderho/golang:1.25.5-alpine3.23@sha256:af19078930f6ab508355e5ed169253d7c862153fe2ccefec67e4eacd3c1d5c84 AS build

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
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& go build -o ./headscale -v -trimpath -ldflags="-s -w -X github.com/juanfont/headscale/cmd/headscale/cli.Version=${BUILD_VERSION}" ./cmd/headscale 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.23.2@sha256:dbfce411d28db252736392199ad89977bb514729a0dcd3737bd1d24e17d6d6db

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

