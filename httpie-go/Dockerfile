FROM ghcr.io/jauderho/golang:1.24.4-alpine3.22@sha256:5527fb3bfaca5aa4409ba4b08b67879e14d786790b4a90ef317b44475f9ebadf AS build

WORKDIR /go/src/github.com/nojima/httpie-go/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/nojima/httpie-go/archive/
ARG GIT_URL=https://github.com/nojima/httpie-go.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git gcc musl-dev \ 
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/nojima/httpie-go \
	&& cd /go/src/github.com/nojima/httpie-go \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& go build -v -trimpath -ldflags="-s -w" ./cmd/ht 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.15.0

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/httpie-go"
LABEL org.opencontainers.image.description="httpie-go is a user-friendly HTTP client CLI"

COPY --from=build /go/src/github.com/nojima/httpie-go/ht /usr/local/bin/ht
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/ht"]

