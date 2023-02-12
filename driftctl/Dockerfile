FROM golang:1.20.0-alpine3.17@sha256:0d145ecb3cb3772ee54d3a97ae2774aa4f8a179f28f9d4ea67b9cb38b58acebd AS build

WORKDIR /go/src/github.com/cloudskiff/driftctl/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/cloudskiff/driftctl/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/driftctl.tar.gz \
	&& tar xzf /tmp/driftctl.tar.gz --strip 1 -C /go/src/github.com/cloudskiff/driftctl \
	&& go build -v -trimpath -ldflags="-s -w -X github.com/cloudskiff/driftctl/pkg/version.version=${BUILD_VERSION}" . 

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

COPY --from=build /go/src/github.com/cloudskiff/driftctl/driftctl /usr/local/bin/driftctl
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/driftctl"]
CMD ["--help"]

