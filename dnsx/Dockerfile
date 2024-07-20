FROM ghcr.io/jauderho/golang:1.22.5-alpine3.20@sha256:42b7c5450e3cbda706037f99f39b8796a40762a1da28261557d1b9bc48a55c88 AS build

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
	&& go mod tidy \
	&& go build -o dnsx -v -trimpath -ldflags="-s -w" cmd/dnsx/dnsx.go 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.20.1@sha256:7be2d5bc23d77fca3910abe49334a98c19240510dc642a20a829b3bafa3b740d

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

