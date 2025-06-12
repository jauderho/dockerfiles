FROM ghcr.io/jauderho/golang:1.24.4-alpine3.22@sha256:e5151d6ba6ffe044cd2359e96d2a8d003d2f60c1b510368e1f998a834dcf8da2 AS build

WORKDIR /go/src/github.com/trufflesecurity/trufflehog/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/trufflesecurity/trufflehog/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/trufflehog.tar.gz \
	&& tar xzf /tmp/trufflehog.tar.gz --strip 1 -C /go/src/github.com/trufflesecurity/trufflehog \
	&& go build -o ./trufflehog -v -trimpath -ldflags="-s -w -X main.Version=${BUILD_VERSION}" .

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.22.0@sha256:20d4337aed348140c72ea8a8d19a5a64b1a946fc5f5d3071753dc1be9204cc6b

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/trufflehog"
LABEL org.opencontainers.image.description="trufflehog finds leaked credentials"

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/trufflesecurity/trufflehog/trufflehog /usr/local/bin/trufflehog
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/trufflehog"]

