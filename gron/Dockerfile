FROM golang:1.19.3-alpine3.16@sha256:d171aa333fb386089206252503bc6ab545072670e0286e3d1bbc644362825c6e AS build

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
#FROM alpine:3.17.0@sha256:8914eb54f968791faf6a8638949e480fef81e697984fba772b3976835194c6d4

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

