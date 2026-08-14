FROM ghcr.io/jauderho/golang:1.26.6-alpine3.24@sha256:fbae660e5e8ec5ad83f726e098c69ca4084d311b7ca0c16bcbda9a6935479fe2 AS build

WORKDIR /go/src/github.com/gravitl/netmaker/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/gravitl/netmaker/archive/refs/tags/

ENV CGO_ENABLED=1

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/netmaker.tar.gz \
	&& tar xzf /tmp/netmaker.tar.gz --strip 1 -C /go/src/github.com/gravitl/netmaker \
	&& go get -u github.com/go-jose/go-jose/v3 github.com/jackc/pgx/v5 \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& CGO_CFLAGS="-D_LARGEFILE64_SOURCE" go build -o ./netmaker -v -trimpath -ldflags="-s -w -X main.version=${BUILD_VERSION}" . 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:e198ded2ad4e953fa5349cd30f01ff6f7d07773254d079df4aca4a6a2dd24bf5

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/netmaker"
LABEL org.opencontainers.image.description="Netmaker automates fast, secure, and distributed virtual networks using Wireguard"

RUN apk update \
	&& apk upgrade -a \
	&& apk --no-cache add gcompat iptables

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/gravitl/netmaker/netmaker /usr/local/bin/netmaker
COPY --from=build /config /config

EXPOSE 8081
EXPOSE 50051

ENTRYPOINT ["/usr/local/bin/netmaker"]
CMD ["help"]

