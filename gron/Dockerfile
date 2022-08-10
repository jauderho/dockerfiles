FROM golang:1.19.0-alpine3.16@sha256:f8e128fa8aa891fe29e22e6401686dffef9bd4c3f5b552b09a7c29f7379979c1 AS build

WORKDIR /go/src/github.com/tomnomnom/gron/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/tomnomnom/gron/archive/
ARG GIT_URL=https://github.com/tomnomnom/gron.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache git ca-certificates \ 
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/tomnomnom/gron \
	&& cd /go/src/github.com/tomnomnom/gron \
	&& go build -v -trimpath -ldflags="-s -w"

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.16.2@sha256:bc41182d7ef5ffc53a40b044e725193bc10142a1243f395ee852a8d9730fc2ad

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/gron"
LABEL org.opencontainers.image.description="gron transforms JSON into manageable chunks"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/tomnomnom/gron/gron /usr/local/bin/gron
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/gron"]

