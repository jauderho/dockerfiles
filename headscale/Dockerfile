FROM golang:1.19.3-alpine3.17@sha256:8bd8a4b55b233ea77a81250f83637553ef9e3348c5a0cc3ce440c5d45bf7d51d AS build

WORKDIR /go/src/github.com/juanfont/headscale/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/juanfont/headscale/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/headscale.tar.gz \
	&& tar xzf /tmp/headscale.tar.gz --strip 1 -C /go/src/github.com/juanfont/headscale \
	&& go build -o ./headscale -v -trimpath -ldflags="-s -w -X github.com/juanfont/headscale/cmd/headscale/cli.Version=${BUILD_VERSION}" ./cmd/headscale 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.17.0@sha256:8914eb54f968791faf6a8638949e480fef81e697984fba772b3976835194c6d4

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/headscale"
LABEL org.opencontainers.image.description="An open source, self-hosted implementation of the Tailscale coordination server."

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/juanfont/headscale/headscale /usr/local/bin/headscale
COPY --from=build /config /config

EXPOSE 8080/tcp

ENTRYPOINT ["/usr/local/bin/headscale"]
CMD ["help"]

