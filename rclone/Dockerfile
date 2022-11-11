FROM golang:1.19.3-alpine3.16@sha256:dc4f4756a4fb91b6f496a958e11e00c0621130c8dfbb31ac0737b0229ad6ad9c AS build

WORKDIR /go/src/github.com/rclone/rclone/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/rclone/rclone/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/rclone.tar.gz \
	&& tar xzf /tmp/rclone.tar.gz --strip 1 -C /go/src/github.com/rclone/rclone \
	&& go build -o rclone -v -trimpath -buildmode=pie -ldflags="-s -w" 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.16.2@sha256:65a2763f593ae85fab3b5406dc9e80f744ec5b449f269b699b5efd37a07ad32e

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/rclone"
LABEL org.opencontainers.image.description="rclone is a cli app to sync files and dirs between cloud providers"

RUN apk --no-cache add ca-certificates fuse tzdata && \
	echo "user_allow_other" >> /etc/fuse.conf && \
	addgroup -g 1009 rclone && \
	adduser -u 1009 -Ds /bin/sh -G rclone rclone

COPY --from=build /go/src/github.com/rclone/rclone/rclone /usr/local/bin/rclone
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/rclone"]

