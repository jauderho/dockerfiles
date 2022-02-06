FROM golang:1.17.6-alpine3.15@sha256:519c827ec22e5cf7417c9ff063ec840a446cdd30681700a16cf42eb43823e27c AS build

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
#FROM alpine:3.15.0@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300

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

