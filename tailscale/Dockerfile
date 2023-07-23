FROM golang:1.20.6-alpine3.18@sha256:7839c9f01b5502d7cb5198b2c032857023424470b3e31ae46a8261ffca72912a AS build

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


FROM alpine:3.18.2@sha256:82d1e9d7ed48a7523bdebc18cf6290bdb97b82302a8a9c27d4fe885949ea94d1

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

