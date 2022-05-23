FROM golang:1.18.2-alpine3.15@sha256:e6b729ae22a2f7b6afcc237f7b9da3a27151ecbdcd109f7ab63a42e52e750262 AS build

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
#FROM alpine:3.16.0@sha256:002e139741ad820846f0c5bb26442468ccafbc0ec1898346613f4d988fc72cd0

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

