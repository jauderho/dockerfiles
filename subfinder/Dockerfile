FROM golang:1.18.0-alpine3.15@sha256:413073fb0136d8c713f2596d0bbdfd42a3bfef291130db5b21a88ad341fff7ac AS build

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
FROM alpine:3.15.4@4edbd2beb5f78b1014028f4fbb99f3237d9561100b6881aabbf5acce2c4f9454

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

