FROM node:26.3.1-alpine3.24@sha256:c6f010471b5bc0d10e673ae3c94c48cd11f7608579344c6b32e52ff98c62a980 AS build

WORKDIR /app

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jauderho/cf-warp/archive/

ADD "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" /tmp/cf-warp.tar.gz

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl yarn \
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



FROM node:26.3.1-alpine3.24@sha256:c6f010471b5bc0d10e673ae3c94c48cd11f7608579344c6b32e52ff98c62a980
#FROM ghcr.io/jauderho/alpine:3.24.1@sha256:c43ea832c5e5df2adadaec0a6487e5939c7080376ed831db9d422067519e86d8

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

