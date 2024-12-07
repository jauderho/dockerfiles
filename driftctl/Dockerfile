FROM ghcr.io/jauderho/golang:1.23.4-alpine3.20@sha256:b9a03910400f9d9ca18918635d05e56f50fa319e63b08a3ea6d9774ea7f3928e AS build

WORKDIR /go/src/github.com/snyk/driftctl/

ARG BUILD_VERSION
#ARG ARCHIVE_URL=https://github.com/snyk/driftctl/archive/
#ARG ARCHIVE_URL=https://github.com/jauderho/driftctl/archive/
ARG GIT_URL=https://github.com/jauderho/driftctl.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates git gcc musl-dev \
	&& update-ca-certificates \
	#&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/driftctl.tar.gz \
	#&& tar xzf /tmp/driftctl.tar.gz --strip 1 -C /go/src/github.com/snyk/driftctl \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/snyk/driftctl \
	&& cd /go/src/github.com/snyk/driftctl \
	&& go get -u github.com/hashicorp/go-getter github.com/dgrijalva/jwt-go golang.org/x/net golang.org/x/crypto \
	&& go mod tidy \
	&& go build -v -trimpath -ldflags="-s -w -X github.com/snyk/driftctl/pkg/version.version=${BUILD_VERSION}" . 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.14

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/driftctl"
LABEL org.opencontainers.image.description="driftctl measures infrastructure as code coverage, and tracks infrastructure drift"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/snyk/driftctl/driftctl /usr/local/bin/driftctl
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/driftctl"]
CMD ["--help"]

