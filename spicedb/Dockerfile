FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.2-alpine3.24@sha256:7e5536c239da1446a5bb798f89db127801d1ec75f1ec533bd8ed2c262369faa7 AS build

WORKDIR /go/src/github.com/authzed/spicedb/

ARG BUILD_VERSION
#ARG ARCHIVE_URL=https://github.com/authzed/spicedb/archive/
ARG ARCHIVE_URL=https://github.com/authzed/spicedb/archive/refs/tags/
ARG TARGETOS
ARG TARGETARCH

ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl \
	&& update-ca-certificates \
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/spicedb.tar.gz \
	&& tar xzf /tmp/spicedb.tar.gz --strip 1 -C /go/src/github.com/authzed/spicedb \
	&& go get -u golang.org/x/net golang.org/x/mod \
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

