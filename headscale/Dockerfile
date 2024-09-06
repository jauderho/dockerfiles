FROM ghcr.io/jauderho/golang:1.23.1-alpine3.20@sha256:eed28d1e78bf849c504230928c030edac93691c7fb413f36ee123f8d6cd8549b AS build

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
FROM ghcr.io/jauderho/alpine:3.20.2@sha256:6f037df56ca0bf09c6854daa341457f5105b1f2ec73b52bc5090026770feb1be

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

