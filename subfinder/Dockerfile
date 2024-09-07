FROM ghcr.io/jauderho/golang:1.23.1-alpine3.20@sha256:eed28d1e78bf849c504230928c030edac93691c7fb413f36ee123f8d6cd8549b AS build

WORKDIR /go/src/github.com/projectdiscovery/subfinder/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/projectdiscovery/subfinder/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/subfinder.tar.gz \
	&& tar xzf /tmp/subfinder.tar.gz --strip 1 -C /go/src/github.com/projectdiscovery/subfinder \
	&& cd v2 \
	&& go get -u github.com/quic-go/quic-go \
	&& go mod tidy \
	&& go build -o subfinder -v -trimpath -ldflags="-s -w" cmd/subfinder/main.go 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.20.3@sha256:3e7fb726bc952e1b23d658c2caaa36e01ef742ae680147db68161ab52b811148

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/subfinder"
LABEL org.opencontainers.image.description="subfinder is a subdomain discovery tool via passive online sources"

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache bind-tools ca-certificates

COPY --from=build /go/src/github.com/projectdiscovery/subfinder/v2/subfinder /usr/local/bin/subfinder
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/subfinder"]
#CMD ["-h"]

