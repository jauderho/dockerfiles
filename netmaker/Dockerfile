FROM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:75f8f4b30907514de96c51f951d84d51160d66fdf51c2e1017e620b8e0207a4a AS build

WORKDIR /go/src/github.com/gravitl/netmaker/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/gravitl/netmaker/archive/refs/tags/

ENV CGO_ENABLED=1

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/netmaker.tar.gz \
	&& tar xzf /tmp/netmaker.tar.gz --strip 1 -C /go/src/github.com/gravitl/netmaker \
	&& go get -u github.com/go-jose/go-jose/v3 github.com/jackc/pgx/v5 \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& CGO_CFLAGS="-D_LARGEFILE64_SOURCE" go build -o ./netmaker -v -trimpath -ldflags="-s -w -X main.version=${BUILD_VERSION}" . 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:17182a5a7a7f13026b02c689a3605b3f4f1eaf743b4c1fc9fbbc23ba80b34b38

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

