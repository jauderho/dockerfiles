FROM golang:alpine as build

WORKDIR /go/src/github.com/tailscale/tailscale

ARG BUILD_VERSION
ARG BUILD_VERSION_LONG
ARG BUILD_VERSION_COMMIT
ARG ARCHIVE_URL=https://github.com/tailscale/tailscale/archive/

ENV GO111MODULE on

ADD . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl \
	&& curl -L "${ARCHIVE_URL}v${BUILD_VERSION}.tar.gz" -o /tmp/tailscale.tar.gz \
	&& tar xzf /tmp/tailscale.tar.gz --strip 1 -C /go/src/github.com/tailscale/tailscale \ 
	&& go build -v -tags xversion -ldflags="-s -w -X tailscale.com/version.Long=${BUILD_VERSION_LONG} -X tailscale.com/version.Short=${BUILD_VERSION} -X tailscale.com/version.GitCommit=${BUILD_VERSION_COMMIT}" tailscale.com/cmd/tailscale \
	&& go build -v -tags xversion -ldflags="-s -w -X tailscale.com/version.Long=${BUILD_VERSION_LONG} -X tailscale.com/version.Short=${BUILD_VERSION} -X tailscale.com/version.GitCommit=${BUILD_VERSION_COMMIT}" tailscale.com/cmd/tailscaled 

RUN cp tailscale /go/bin/tailscale
RUN cp tailscaled /go/bin/tailscaled
RUN tailscale version

# ----------------------------------------------------------------------------

FROM alpine:latest

LABEL org.opencontainers.image.authors "Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url "https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation "https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source "https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title "jauderho/tailscale"
LABEL org.opencontainers.image.description "Tailscale is Wireguard made easy"

RUN apk add --no-cache ca-certificates iptables iproute2

COPY --from=build /go/bin/tailscale /usr/local/bin
COPY --from=build /go/bin/tailscaled /usr/local/bin

WORKDIR /tailscale

#RUN dnscontrol version
RUN ["tailscale", "version"]

CMD tailscale
