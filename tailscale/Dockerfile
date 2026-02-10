FROM ghcr.io/jauderho/golang:1.26.0-alpine3.23@sha256:27cd81db958a6786bc9285ecbcb6020c4b6010a37d0640aee8f4998c26233090 AS build

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
	&& go get -u golang.org/x/net \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& go build -v -trimpath -tags xversion,ts_include_cli -ldflags="-s -w -X tailscale.com/version.Short=${BUILD_VERSION}" tailscale.com/cmd/tailscaled 

# Validation check
#RUN cp tailscale /go/bin/tailscale
RUN cp tailscaled /go/bin/tailscaled
#RUN tailscale version


# ----------------------------------------------------------------------------


FROM ghcr.io/jauderho/alpine:3.23.3@sha256:350bc73d1a938d40605f8ecd1009be511e61804d8452af018d63b8eac931fe33

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

