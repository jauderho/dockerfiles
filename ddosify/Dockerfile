FROM golang:1.20.2-alpine3.17@sha256:e03044ec19ae333714d136a9c8ec2d47330e2b3ac74b7c0303d9e780387e60fa AS build

WORKDIR /go/src/github.com/ddosify/ddosify/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/ddosify/ddosify/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/ddosify.tar.gz \
	&& tar xzf /tmp/ddosify.tar.gz --strip 1 -C /go/src/github.com/ddosify/ddosify \
	&& go build -o ddosify -v -trimpath -buildmode=pie -ldflags="-s -w" ./main.go 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.17.3@sha256:124c7d2707904eea7431fffe91522a01e5a861a624ee31d03372cc1d138a3126

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/ddosify"
LABEL org.opencontainers.image.description="ddosify is a high performance load testing tool"

RUN apk update \
	&& apk upgrade -a

COPY --from=build /go/src/github.com/ddosify/ddosify/ddosify /usr/local/bin/ddosify
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/ddosify"]
CMD ["-h"]

