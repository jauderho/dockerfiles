FROM golang:1.19.3-alpine3.16@sha256:d171aa333fb386089206252503bc6ab545072670e0286e3d1bbc644362825c6e AS build

WORKDIR /go/src/github.com/tomnomnom/httprobe/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/tomnomnom/httprobe/archive/
ARG GIT_URL=https://github.com/tomnomnom/httprobe.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache git gcc musl-dev \ 
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/tomnomnom/httprobe \
	&& cd /go/src/github.com/tomnomnom/httprobe \
	&& go build -o httprobe -v -trimpath -buildmode=pie -ldflags="-s -w" main.go  

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.17.0@sha256:8914eb54f968791faf6a8638949e480fef81e697984fba772b3976835194c6d4

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/httprobe"
LABEL org.opencontainers.image.description="httprobe probes for working http and https servers"

COPY --from=build /go/src/github.com/tomnomnom/httprobe/httprobe /usr/local/bin/httprobe
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/httprobe"]

