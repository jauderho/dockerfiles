FROM ghcr.io/jauderho/golang:1.24.4-alpine3.22@sha256:5527fb3bfaca5aa4409ba4b08b67879e14d786790b4a90ef317b44475f9ebadf AS build

WORKDIR /go/src/github.com/openrdap/rdap/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/openrdap/rdap/archive/
ARG GIT_URL=https://github.com/jauderho/rdap.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git ca-certificates \ 
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/openrdap/rdap \
	&& cd /go/src/github.com/openrdap/rdap \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go get -u \
	&& go build -o rdap -v -trimpath -ldflags="-s -w" ./cmd/rdap

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.17.2@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/rdap"
LABEL org.opencontainers.image.description="OpenRDAP is an command line RDAP client implementation in Go"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/openrdap/rdap/rdap /usr/local/bin/rdap
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/rdap"]

