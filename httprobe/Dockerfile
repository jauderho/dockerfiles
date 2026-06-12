FROM ghcr.io/jauderho/golang:1.26.4-alpine3.24@sha256:9589588fd5fda0a4aba042a5ce52f4fe60778929c29efcf70106de10cf9af8bc AS build

WORKDIR /go/src/github.com/tomnomnom/httprobe/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/tomnomnom/httprobe/archive/
ARG GIT_URL=https://github.com/tomnomnom/httprobe.git

ENV CGO_ENABLED=0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git gcc musl-dev \ 
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/tomnomnom/httprobe \
	&& cd /go/src/github.com/tomnomnom/httprobe \
	&& go build -o httprobe -v -trimpath -ldflags="-s -w" main.go  

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.0@sha256:2b33bf7098b70256590a938abfa745b70ba3d8b8f8cce356402e5a92833e4bdd

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/httprobe"
LABEL org.opencontainers.image.description="httprobe probes for working http and https servers"

RUN apk update \
	&& apk upgrade -a

COPY --from=build /go/src/github.com/tomnomnom/httprobe/httprobe /usr/local/bin/httprobe
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/httprobe"]

