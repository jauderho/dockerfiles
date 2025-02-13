FROM ghcr.io/jauderho/golang:1.24.0-alpine3.21@sha256:157489c5bfe3d9b577009dcc142e1323666ea25d42353d9adabdd434c8a0a007 AS build

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
FROM ghcr.io/jauderho/alpine:3.21.2@sha256:e7f3117165afa2d56675922cdb717f94b22f724b385e07bfa096ede4ee58c323

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

