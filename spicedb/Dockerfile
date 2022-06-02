FROM golang:1.18.3-alpine3.16@sha256:7cc62574fcf9c5fb87ad42a9789d5539a6a085971d58ee75dd2ee146cb8a8695 AS build

WORKDIR /go/src/github.com/authzed/spicedb/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/authzed/spicedb/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/spicedb.tar.gz \
	&& tar xzf /tmp/spicedb.tar.gz --strip 1 -C /go/src/github.com/authzed/spicedb \
	&& go build -o ./spicedb -v -trimpath -ldflags="-s -w" ./cmd/spicedb 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.14

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/spicedb"
LABEL org.opencontainers.image.description="SpiceDB is a Zanzibar-inspired database that stores, computes, and validates application permissions."

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/authzed/spicedb/spicedb /usr/local/bin/spicedb
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/spicedb"]
CMD ["help"]

