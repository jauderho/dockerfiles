FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:acb2ce37623dc9b32cca8e204995298705b7341c4b00bfb9f22db47221ec2927 AS build

WORKDIR /go/src/github.com/projectdiscovery/subfinder/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/projectdiscovery/subfinder/archive/

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/subfinder.tar.gz \
	&& tar xzf /tmp/subfinder.tar.gz --strip 1 -C /go/src/github.com/projectdiscovery/subfinder \
	&& go get -u github.com/quic-go/quic-go \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& GOARM="${TARGETVARIANT#v}" go build -o subfinder -v -trimpath -ldflags="-s -w" cmd/subfinder/main.go 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:ef5927339b32bb8cf4a75ae37951bfc27979be5183802ac1f3446abf4279be42

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/subfinder"
LABEL org.opencontainers.image.description="subfinder is a subdomain discovery tool via passive online sources"

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache bind-tools ca-certificates

COPY --from=build /go/src/github.com/projectdiscovery/subfinder/subfinder /usr/local/bin/subfinder
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/subfinder"]
#CMD ["-h"]

