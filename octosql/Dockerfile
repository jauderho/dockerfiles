FROM ghcr.io/jauderho/golang:1.23.4-alpine3.21@sha256:415d3708577f3dea57d7b5e1c07381bf1aab272fdea191a7822c1574077e9454 AS build

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
	&& go get -u golang.org/x/net golang.org/x/crypto gopkg.in/yaml.v3 github.com/jackc/pgx google.golang.org/grpc google.golang.org/genproto github.com/mholt/archiver \
	&& go get -u github.com/jackc/pgx/v4 \
	&& sed -i "s#github.com/jackc/pgx#github.com/jackc/pgx/v4#" datasources/docs/database.go \
	&& sed -i "s#github.com/jackc/pgx#github.com/jackc/pgx/v4#" datasources/plugins/database.go \
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

