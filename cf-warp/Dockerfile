FROM node:24.3.0-alpine3.22@sha256:49e45bf002728e35c3a466737d8bcfe12c29731c7c2f3e223f9a7c794fff19a4 AS build

WORKDIR /app

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jauderho/cf-warp/archive/

ADD "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" /tmp/cf-warp.tar.gz

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl \
	&& update-ca-certificates \
	#&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/cf-warp.tar.gz \
	&& tar xzf /tmp/cf-warp.tar.gz --strip 1 -C /app \
	#&& yarn set version berry \
	&& yarn install \
	&& yarn upgrade --latest \
	&& yarn --ignore-optional \
	#&& yarn up
	&& yarn outdated



# ----------------------------------------------------------------------------



FROM node:24.3.0-alpine3.22@sha256:49e45bf002728e35c3a466737d8bcfe12c29731c7c2f3e223f9a7c794fff19a4
#FROM ghcr.io/jauderho/alpine:3.22.0@sha256:20d4337aed348140c72ea8a8d19a5a64b1a946fc5f5d3071753dc1be9204cc6b

WORKDIR /app

RUN apk update \
	&& apk upgrade -a \
	#&& apk --no-cache add --upgrade busybox ssl_client nodejs-current \
	#&& apk --no-cache add --upgrade busybox ssl_client nodejs \
	&& apk add --no-cache --upgrade busybox ssl_client  \
	#&& apk add --no-cache -X https://dl-cdn.alpinelinux.org/alpine/edge/community nodejs-current \
	&& rm -rf /var/cache/apk/*

COPY --from=build /app .

ENTRYPOINT ["node", "cli.js"]

