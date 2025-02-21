FROM node:23.8-alpine3.21@sha256:0a29d8a047149079bf48dab598f287815e39867d547e8f3935cfdece0a4379cc AS build

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



FROM ghcr.io/jauderho/alpine:3.21.3@sha256:8139b5dd95ef46202c45b611a4b7e972defda480df2e058b95b6a07b4f2e96c4

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

