FROM golang:1.21.1-alpine3.18@sha256:96634e55b363cb93d39f78fb18aa64abc7f96d372c176660d7b8b6118939d97b AS build

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
	&& go get -u golang.org/x/crypto \
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

