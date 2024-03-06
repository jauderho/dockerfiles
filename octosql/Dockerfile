FROM golang:1.22.1-alpine3.19@sha256:fc5e5848529786cf1136563452b33d713d5c60b2c787f6b2a077fa6eeefd9114 AS build

WORKDIR /go/src/github.com/cube2222/octosql/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/cube2222/octosql/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/octosql.tar.gz \
	&& tar xzf /tmp/octosql.tar.gz --strip 1 -C /go/src/github.com/cube2222/octosql \
	&& go get -u golang.org/x/net golang.org/x/crypto gopkg.in/yaml.v3 \
	&& go mod tidy \
	&& go build -o octosql -v -trimpath -ldflags="-s -w -X github.com/cube2222/octosql/cmd.VERSION=${BUILD_VERSION}" . 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.15

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/octosql"
LABEL org.opencontainers.image.description="OctoSQL is a query tool that joins, analyses and transforms data from multiple databases"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/cube2222/octosql/octosql/octosql /usr/local/bin/octosql
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/octosql"]
CMD ["--help"]

