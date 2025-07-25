FROM ghcr.io/jauderho/golang:1.24.5-alpine3.22@sha256:b161a1a5aeabb6b5ef08854550dbe9843f3da755440576068a0fab3e0287512a AS build

WORKDIR /go/src/github.com/tsenart/vegeta/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/tsenart/vegeta/archive/
ARG GIT_URL=https://github.com/tsenart/vegeta.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc musl-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/tsenart/vegeta \
	&& cd /go/src/github.com/tsenart/vegeta \
	&& go get -u golang.org/x/sys golang.org/x/tools \
	&& go get -u ./... \
	&& go get -u all \
	&& go mod tidy \
	&& go build -o ./vegeta -v -trimpath -ldflags="-s -w -X main.Version=${BUILD_VERSION}" .

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.17.2@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/vegeta"
LABEL org.opencontainers.image.description="Vegeta is a versatile HTTP load testing tool built to drill HTTP services at a constant request rate"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/tsenart/vegeta/vegeta /usr/local/bin/vegeta
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/vegeta"]

