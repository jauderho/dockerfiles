FROM ghcr.io/jauderho/golang:1.26.4-alpine3.24@sha256:aea122b2bd93a09369064c7b7062c2c61c88b8a9a821256684ac623838e2bdef AS build

WORKDIR /go/src/github.com/getanteon/anteon/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/getanteon/anteon/archive/

ENV GO111MODULE=on
ENV CGO_ENABLED=0

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
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:f6f37f85a5fcc44f67b6f62b16b745d6e1fcb21e4cc969d4cc410196035225a9

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

