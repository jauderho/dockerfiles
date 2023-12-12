FROM golang:1.21.5-alpine3.19@sha256:feceecc0e1d73d085040a8844de11a2858ba4a0c58c16a672f1736daecc2a4ff AS build

WORKDIR /go/src/github.com/tomnomnom/gron/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/tomnomnom/gron/archive/
ARG GIT_URL=https://github.com/tomnomnom/gron.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git ca-certificates \ 
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/tomnomnom/gron \
	&& cd /go/src/github.com/tomnomnom/gron \
	&& go build -v -trimpath -ldflags="-s -w"

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.17.2@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a

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

