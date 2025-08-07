FROM ghcr.io/jauderho/golang:1.24.6-alpine3.22@sha256:b23ebfd210ae2da07ef6a86677256199bd7d34323188ce5d30f70cf1ec206acb AS build

WORKDIR /go/src/github.com/0xInfection/logmepwn

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/0xInfection/logmepwn/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/logmepwn.tar.gz \
	&& tar xzf /tmp/logmepwn.tar.gz --strip 1 -C /go/src/github.com/0xInfection/logmepwn \ 
	&& go get -u golang.org/x/crypto golang.org/x/net github.com/valyala/fasthttp \ 
	&& go build -o lmp -v -trimpath -ldflags="-s -w" .

# Validation check
RUN cp lmp /go/bin/lmp



# ----------------------------------------------------------------------------



#FROM scratch
FROM ghcr.io/jauderho/alpine:3.22.1@sha256:6cedbe16d634f856346fb6224aeddf939413076aaf08bc0216a2ee1759917a56

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/logmepwn"
LABEL org.opencontainers.image.description="logmepwn is a mass scanner for log4shell"

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates \
	&& update-ca-certificates \
	&& rm -rf /var/cache/apk/*

COPY --from=build /go/bin/lmp /usr/local/bin

WORKDIR /lmp

ENTRYPOINT ["lmp"]

