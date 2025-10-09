FROM ghcr.io/jauderho/golang:1.25.2-alpine3.22@sha256:c7f5a8fa3f86fb9e42d503b0f677097e082481240573d209ea96a4952828121f AS build

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
FROM ghcr.io/jauderho/alpine:3.22.2@sha256:04d9f90216e3b84c1919a9cd1f7f06fdb3e44091d822c203e44f1ee282cd4c3a

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

