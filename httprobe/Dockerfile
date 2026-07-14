FROM ghcr.io/jauderho/golang:1.26.5-alpine3.24@sha256:8ecb660f538cfda32a212bdac5ed51e0a9c7b5f47bf1dd0f769ea6dd6c0690b2 AS build

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
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:e5a3d6b80d37ba48554e42e212f08c3c100cdcf527948853206574b7c06e209f

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

