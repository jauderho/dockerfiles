FROM golang:1.22.5-alpine3.20@sha256:8c9183f715b0b4eca05b8b3dbf59766aaedb41ec07477b132ee2891ac0110a07 AS build

WORKDIR /go/src/github.com/tomnomnom/httprobe/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/tomnomnom/httprobe/archive/
ARG GIT_URL=https://github.com/tomnomnom/httprobe.git

ENV CGO_ENABLED 0

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
FROM alpine:3.20.1@sha256:b89d9c93e9ed3597455c90a0b88a8bbb5cb7188438f70953fede212a0c4394e0

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

