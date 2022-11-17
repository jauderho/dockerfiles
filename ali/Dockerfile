FROM golang:1.19.3-alpine3.16@sha256:d171aa333fb386089206252503bc6ab545072670e0286e3d1bbc644362825c6e AS build

WORKDIR /go/src/github.com/nakabonne/ali/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/nakabonne/ali/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
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
#FROM alpine:3.14

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

