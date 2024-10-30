FROM node:23.1-alpine3.20@sha256:1467ea23cce893347696b155b9e00e7f0ac7d21555eb6f27236f1328212e045e AS build

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



FROM ghcr.io/jauderho/alpine:3.20.3@sha256:695b84f27b7d942f137aaece7ed982bc198bebc8187121f1fe0112ee0259cf0f

WORKDIR /app

RUN apk update \
	&& apk upgrade -a \
	#&& apk --no-cache add --upgrade busybox ssl_client nodejs-current \
	#&& apk --no-cache add --upgrade busybox ssl_client nodejs \
	&& apk add --no-cache --upgrade busybox ssl_client  \
	&& apk add --no-cache -X https://dl-cdn.alpinelinux.org/alpine/edge/community nodejs-current \
	&& rm -rf /var/cache/apk/*

COPY --from=build /app .

ENTRYPOINT ["node", "cli.js"]

