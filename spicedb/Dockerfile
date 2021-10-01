FROM golang:alpine AS build

WORKDIR /go/src/github.com/authzed/spicedb/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/authzed/spicedb/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/spicedb.tar.gz \
	&& tar xzf /tmp/spicedb.tar.gz --strip 1 -C /go/src/github.com/authzed/spicedb \
	&& go build -o ./spicedb -v -ldflags="-s -w" ./cmd/spicedb 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.14

LABEL org.opencontainers.imspicedb.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.imspicedb.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.imspicedb.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.imspicedb.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.imspicedb.title="jauderho/spicedb"
LABEL org.opencontainers.imspicedb.description="SpiceDB is a Zanzibar-inspired database that stores, computes, and validates application permissions."

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/authzed/spicedb/spicedb /usr/local/bin/spicedb
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/spicedb"]
CMD ["help"]

