FROM golang:1.19.2-alpine3.16@sha256:f3e683657ddf73726b5717c2ff80cdcd9e9efb7d81f77e4948fada9a10dc7257 AS build

WORKDIR /go/src/github.com/likexian/whois/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/likexian/whois/archive/
ARG GIT_URL=https://github.com/jauderho/whois.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache git ca-certificates \ 
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/likexian/whois \
	&& cd /go/src/github.com/likexian/whois \
	&& go get -u all \
	&& go build -o whois -v -trimpath -ldflags="-s -w" ./cmd/whois

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.16.2@sha256:bc41182d7ef5ffc53a40b044e725193bc10142a1243f395ee852a8d9730fc2ad

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/whois"
LABEL org.opencontainers.image.description="whois is a Go implementation of WHOIS with optional JSON output"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/likexian/whois/whois /usr/local/bin/whois
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/whois"]

