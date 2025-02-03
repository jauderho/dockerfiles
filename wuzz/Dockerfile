FROM ghcr.io/jauderho/golang:1.23.5-alpine3.21@sha256:d95ea7f720569c83bfa9c3b52e4e083e73fac1d065fa2e5d84cbd15d88a29029 AS build

WORKDIR /go/src/github.com/asciimoo/wuzz/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/asciimoo/wuzz/archive/
ARG GIT_URL=https://github.com/jauderho/wuzz.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc musl-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/asciimoo/wuzz \
	&& cd /go/src/github.com/asciimoo/wuzz \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go build -v -trimpath -ldflags="-s -w" . 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.21.2@sha256:b4204281fb27e81009c63d368ed26377a2657689304189f3470ec6d977af1a2a

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/wuzz"
LABEL org.opencontainers.image.description="wuzz is an interactive cli tool for HTTP inspection"

RUN apk update \
	&& apk upgrade -a 

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/asciimoo/wuzz/wuzz /usr/local/bin/wuzz
COPY --from=build /config /config

#ENTRYPOINT ["/usr/local/bin/wuzz"]

# wuzz does not want to start up consistently unless sleep 1 is used.It would be better if we could just directly enter into the binary
ENTRYPOINT ["sh", "-c", "sleep 1 ; /usr/local/bin/wuzz"]

