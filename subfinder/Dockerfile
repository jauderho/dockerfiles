FROM golang:1.18.0-alpine3.15@sha256:9efe6b075e2bd5eff0fae9ce2961897ac339ef31eec24732691e15be0a154eec AS build

WORKDIR /go/src/github.com/projectdiscovery/subfinder/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/projectdiscovery/subfinder/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/subfinder.tar.gz \
	&& tar xzf /tmp/subfinder.tar.gz --strip 1 -C /go/src/github.com/projectdiscovery/subfinder \
	&& cd v2 \
	&& go build -o subfinder -v -trimpath -buildmode=pie -ldflags="-s -w" cmd/subfinder/main.go 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.15.1@sha256:d6d0a0eb4d40ef96f2310ead734848b9c819bb97c9d846385c4aca1767186cd4

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/subfinder"
LABEL org.opencontainers.image.description="subfinder is a subdomain discovery tool via passive online sources"

RUN apk add --no-cache bind-tools ca-certificates

COPY --from=build /go/src/github.com/projectdiscovery/subfinder/v2/subfinder /usr/local/bin/subfinder
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/subfinder"]
#CMD ["-h"]

