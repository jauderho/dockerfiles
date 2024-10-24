FROM ghcr.io/jauderho/golang:1.23.2-alpine3.20@sha256:e6392259eb415feabbb1ee3fa305e8c882388cc72adf5dba2eb519840168ec0d AS build

WORKDIR /go/src/github.com/authzed/spicedb/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/authzed/spicedb/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
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

