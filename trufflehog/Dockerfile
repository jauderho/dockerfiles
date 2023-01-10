FROM golang:1.19.4-alpine3.17@sha256:86d32cc0dfc04757fd8aeebb86308e6d1e3de60c73cb59e0f99c7b2ef77416b6 AS build

WORKDIR /go/src/github.com/trufflesecurity/trufflehog/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/trufflesecurity/trufflehog/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/trufflehog.tar.gz \
	&& tar xzf /tmp/trufflehog.tar.gz --strip 1 -C /go/src/github.com/trufflesecurity/trufflehog \
	&& go build -o ./trufflehog -v -trimpath -ldflags="-s -w -X main.Version=${BUILD_VERSION}" .

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.17.1@sha256:f271e74b17ced29b915d351685fd4644785c6d1559dd1f2d4189a5e851ef753a

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/trufflehog"
LABEL org.opencontainers.image.description="trufflehog finds leaked credentials"

RUN apk add --no-cache git

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/trufflesecurity/trufflehog/trufflehog /usr/local/bin/trufflehog
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/trufflehog"]

