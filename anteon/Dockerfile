FROM ghcr.io/jauderho/golang:1.26.0-alpine3.23@sha256:27cd81db958a6786bc9285ecbcb6020c4b6010a37d0640aee8f4998c26233090 AS build

WORKDIR /go/src/github.com/getanteon/anteon/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/getanteon/anteon/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/anteon.tar.gz \
	&& tar xzf /tmp/anteon.tar.gz --strip 1 -C /go/src/github.com/getanteon/anteon \
	&& cd ddosify_engine \
	&& go get -u golang.org/x/net \
	&& go mod tidy \
	&& go build -o ddosify -v -trimpath -ldflags="-s -w" ./main.go 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.23.3@sha256:350bc73d1a938d40605f8ecd1009be511e61804d8452af018d63b8eac931fe33

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/anteon"
LABEL org.opencontainers.image.description="anteon is a high performance load testing tool"

RUN apk update \
	&& apk upgrade -a

COPY --from=build /go/src/github.com/getanteon/anteon/ddosify_engine/ddosify /usr/local/bin/ddosify
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/ddosify"]
CMD ["-h"]

