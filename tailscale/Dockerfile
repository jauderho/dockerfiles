FROM golang:1.20.2-alpine3.17@sha256:e03044ec19ae333714d136a9c8ec2d47330e2b3ac74b7c0303d9e780387e60fa AS build

WORKDIR /go/src/github.com/tailscale/tailscale

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/tailscale/tailscale/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/tailscale.tar.gz \
	&& tar xzf /tmp/tailscale.tar.gz --strip 1 -C /go/src/github.com/tailscale/tailscale \ 
	&& go build -v -trimpath -buildmode=pie -tags xversion,ts_include_cli -ldflags="-s -w -X tailscale.com/version.Short=${BUILD_VERSION}" tailscale.com/cmd/tailscaled 

# Validation check
#RUN cp tailscale /go/bin/tailscale
RUN cp tailscaled /go/bin/tailscaled
#RUN tailscale version


# ----------------------------------------------------------------------------


FROM alpine:3.17.3@sha256:124c7d2707904eea7431fffe91522a01e5a861a624ee31d03372cc1d138a3126

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/tailscale"
LABEL org.opencontainers.image.description="Tailscale is Wireguard made easy"

#COPY --from=build /go/bin/tailscale /usr/local/bin
COPY --from=build /go/bin/tailscaled /usr/local/bin

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates iptables ip6tables iproute2 \
	&& update-ca-certificates \
	&& ln -s /usr/local/bin/tailscaled /usr/local/bin/tailscale \
	&& rm -rf /var/cache/apk/*

WORKDIR /tailscale

CMD ["tailscaled"]

