FROM ghcr.io/jauderho/golang:1.24.3-alpine3.21@sha256:4b6d42f444193a96e296691ac8ddf0902aa28bddefb58a366d03b299e7ebc1d3 AS build

WORKDIR /go/src/github.com/rclone/rclone/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/rclone/rclone/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/rclone.tar.gz \
	&& tar xzf /tmp/rclone.tar.gz --strip 1 -C /go/src/github.com/rclone/rclone \
	&& go get -u golang.org/x/net \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& go build -o rclone -v -trimpath -ldflags="-s -w" 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.21.3@sha256:97544ae64f3bad300d3130639f26ffa5465257222c0dc58e08be0276d017df68

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/rclone"
LABEL org.opencontainers.image.description="rclone is a cli app to sync files and dirs between cloud providers"

RUN apk update \
	&& apk upgrade -a \
	&& apk --no-cache add ca-certificates fuse tzdata \
	&& echo "user_allow_other" >> /etc/fuse.conf \
	&& addgroup -g 1009 rclone \
	&& adduser -u 1009 -Ds /bin/sh -G rclone rclone

COPY --from=build /go/src/github.com/rclone/rclone/rclone /usr/local/bin/rclone
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/rclone"]

