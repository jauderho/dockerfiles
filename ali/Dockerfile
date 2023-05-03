FROM golang:1.20.4-alpine3.17@sha256:913de96707b0460bcfdfe422796bb6e559fc300f6c53286777805a9a3010a5ea AS build

WORKDIR /go/src/github.com/nakabonne/ali/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/nakabonne/ali/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/ali.tar.gz \
	&& tar xzf /tmp/ali.tar.gz --strip 1 -C /go/src/github.com/nakabonne/ali \
	&& echo "after" \
	&& ls -l \
	&& go build -v -trimpath -ldflags="-s -w -X main.version=${BUILD_VERSION}" . 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/ali"
LABEL org.opencontainers.image.description="ali is a load testing tool capable of performing real-time analysis"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/nakabonne/ali/ali /usr/local/bin/ali
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/ali"]
CMD ["--help"]

