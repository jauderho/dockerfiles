FROM ghcr.io/jauderho/golang:1.24.4-alpine3.22@sha256:e5151d6ba6ffe044cd2359e96d2a8d003d2f60c1b510368e1f998a834dcf8da2 AS build

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
FROM ghcr.io/jauderho/alpine:3.22.0@sha256:20d4337aed348140c72ea8a8d19a5a64b1a946fc5f5d3071753dc1be9204cc6b

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

