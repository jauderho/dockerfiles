FROM ghcr.io/jauderho/golang:1.23.4-alpine3.21@sha256:415d3708577f3dea57d7b5e1c07381bf1aab272fdea191a7822c1574077e9454 AS build

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
FROM ghcr.io/jauderho/alpine:3.21.0@sha256:f1c32703dfc24d994cb29a14dba612df8cd56ef5c4df8e443803d11cacadd150

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

