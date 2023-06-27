FROM node:20.3-alpine3.18@sha256:f77f29bc47124b393d8e7ae947be385e851d7c448d85ab87a4c077af84ee8ea2 AS build

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



FROM alpine:3.18.2@sha256:82d1e9d7ed48a7523bdebc18cf6290bdb97b82302a8a9c27d4fe885949ea94d1

WORKDIR /app

RUN apk update \
	&& apk upgrade -a \
	&& apk --no-cache add --upgrade busybox ssl_client nodejs-current \
	&& rm -rf /var/cache/apk/*

COPY --from=build /app .

ENTRYPOINT ["node", "cli.js"]

