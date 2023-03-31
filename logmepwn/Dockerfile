FROM golang:1.20.2-alpine3.17@sha256:87734b78d26a52260f303cf1b40df45b0797f972bd0250e56937c42114bf472c AS build

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
	&& go build -o lmp -v -trimpath -buildmode=pie -ldflags="-s -w" .

# Validation check
RUN cp lmp /go/bin/lmp



# ----------------------------------------------------------------------------



#FROM scratch
FROM alpine:3.17.3@sha256:124c7d2707904eea7431fffe91522a01e5a861a624ee31d03372cc1d138a3126

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

