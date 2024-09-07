FROM ghcr.io/jauderho/golang:1.23.1-alpine3.20@sha256:eed28d1e78bf849c504230928c030edac93691c7fb413f36ee123f8d6cd8549b AS build

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
FROM ghcr.io/jauderho/alpine:3.20.3@sha256:3e7fb726bc952e1b23d658c2caaa36e01ef742ae680147db68161ab52b811148

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

