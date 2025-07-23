FROM ghcr.io/jauderho/golang:1.24.5-alpine3.22@sha256:5cbb5ac8d0f00c34bee3b18657eaf46a1582fbc8ee1f7ab0bbeffd11540f268a AS build

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

