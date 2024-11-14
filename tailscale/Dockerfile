FROM ghcr.io/jauderho/golang:1.23.3-alpine3.20@sha256:dce068d056966f5f51c72ce9e5c268d01fffdd1ecf92424a2646efaddf952c1b AS build

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
	&& go mod tidy \
	&& go build -v -trimpath -tags xversion,ts_include_cli -ldflags="-s -w -X tailscale.com/version.Short=${BUILD_VERSION}" tailscale.com/cmd/tailscaled 

# Validation check
#RUN cp tailscale /go/bin/tailscale
RUN cp tailscaled /go/bin/tailscaled
#RUN tailscale version


# ----------------------------------------------------------------------------


FROM ghcr.io/jauderho/alpine:3.20.3@sha256:695b84f27b7d942f137aaece7ed982bc198bebc8187121f1fe0112ee0259cf0f

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

