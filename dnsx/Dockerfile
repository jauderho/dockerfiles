FROM ghcr.io/jauderho/golang:1.24.4-alpine3.22@sha256:e5151d6ba6ffe044cd2359e96d2a8d003d2f60c1b510368e1f998a834dcf8da2 AS build

WORKDIR /go/src/github.com/projectdiscovery/dnsx/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/projectdiscovery/dnsx/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/dnsx.tar.gz \
	&& tar xzf /tmp/dnsx.tar.gz --strip 1 -C /go/src/github.com/projectdiscovery/dnsx \
	&& go get -u github.com/quic-go/quic-go \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& go build -o dnsx -v -trimpath -ldflags="-s -w" cmd/dnsx/dnsx.go 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.22.0@sha256:bcec51c688c49175fe5ab5204735ec7051349ac0e52f115dd8505aa5d0558e74

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dnsx"
LABEL org.opencontainers.image.description="dnsx is a fast and multi-purpose DNS toolkit"

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache bind-tools ca-certificates

COPY --from=build /go/src/github.com/projectdiscovery/dnsx/dnsx /usr/local/bin/dnsx
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/dnsx"]
CMD ["-h"]

