FROM ghcr.io/jauderho/golang:1.25.1-alpine3.22@sha256:6c605f5c0500f90666d5ef4fe1d47f4bc3cd88cd495a743a8c6ceb3d4c19bcec AS build

WORKDIR /go/src/github.com/kffl/gocannon/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/kffl/gocannon/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/gocannon.tar.gz \
	&& tar xzf /tmp/gocannon.tar.gz --strip 1 -C /go/src/github.com/kffl/gocannon \
	&& go build -v -trimpath -ldflags="-s -w" . 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.14

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/gocannon"
LABEL org.opencontainers.image.description="Gocannon is a lightweight HTTP benchmarking tool"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/kffl/gocannon/gocannon /usr/local/bin/gocannon
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/gocannon"]
CMD ["--help"]

