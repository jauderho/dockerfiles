FROM golang:alpine3.16@sha256:9c621254fe1ff5a00291eb689b1be2ce4744eee678e33189f2fd7b4fc726cff4 AS build

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
FROM alpine:3.16.1@sha256:7580ece7963bfa863801466c0a488f11c86f85d9988051a9f9c68cb27f6b7872

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

