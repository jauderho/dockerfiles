FROM ghcr.io/jauderho/golang:1.26rc3-alpine3.23@sha256:47615064e3dd04d323631f1bbec61967fd296e87785405b005ae1d4e0fd5920a AS build

WORKDIR /go/src/github.com/likexian/whois/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/likexian/whois/archive/
ARG GIT_URL=https://github.com/likexian/whois.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git ca-certificates \ 
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/likexian/whois \
	&& cd /go/src/github.com/likexian/whois \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go get -u all \
	&& go build -o whois -v -trimpath -ldflags="-s -w" ./cmd/whois

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.17.2@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a

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

