FROM golang:1.18.0-alpine3.15@sha256:a2ca4f4c0828b1b426a3153b068bf32a21868911c57a9fc4dccdc5fbb6553b35 AS build

WORKDIR /go/src/github.com/tsenart/vegeta/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/tsenart/vegeta/archive/
ARG PKGSRC=github.com/tsenart/vegeta/src/version

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/vegeta.tar.gz \
	&& tar xzf /tmp/vegeta.tar.gz --strip 1 -C /go/src/github.com/tsenart/vegeta \
	&& go build -o ./vegeta -v -trimpath -ldflags="-s -w -X main.Version=${BUILD_VERSION}" .

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.15.4@sha256:4edbd2beb5f78b1014028f4fbb99f3237d9561100b6881aabbf5acce2c4f9454

LABEL org.opencontainers.imvegeta.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.imvegeta.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.imvegeta.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.imvegeta.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.imvegeta.title="jauderho/vegeta"
LABEL org.opencontainers.imvegeta.description="Vegeta is a versatile HTTP load testing tool built to drill HTTP services at a constant request rate"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/tsenart/vegeta/vegeta /usr/local/bin/vegeta
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/vegeta"]

