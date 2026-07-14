FROM ghcr.io/jauderho/golang:1.26.5-alpine3.24@sha256:8ecb660f538cfda32a212bdac5ed51e0a9c7b5f47bf1dd0f769ea6dd6c0690b2 AS build

WORKDIR /go/src/github.com/ddosify/ddosify/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/ddosify/ddosify/archive/

ENV GO111MODULE=on
ENV CGO_ENABLED=0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/ddosify.tar.gz \
	&& tar xzf /tmp/ddosify.tar.gz --strip 1 -C /go/src/github.com/ddosify/ddosify \
	&& go get -u golang.org/x/net \
	&& go mod tidy \
	&& go build -o ddosify -v -trimpath -ldflags="-s -w" ./main.go 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:e5a3d6b80d37ba48554e42e212f08c3c100cdcf527948853206574b7c06e209f

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

