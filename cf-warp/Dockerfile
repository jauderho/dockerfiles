FROM node:20.5-alpine3.18@sha256:59ecf4c430fc6e15b3e6f2ee3ae8fa9773b2508856baf376fcd9ad7b1e6934a9 AS build

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



FROM alpine:3.18.3@sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a

WORKDIR /app

RUN apk update \
	&& apk upgrade -a \
	&& apk --no-cache add --upgrade busybox ssl_client nodejs-current \
	&& rm -rf /var/cache/apk/*

COPY --from=build /app .

ENTRYPOINT ["node", "cli.js"]

