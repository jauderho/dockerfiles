FROM node:21.2-alpine3.18@sha256:4a512d1538b1a8281b58cab0b366a5c62436566bb63e7dcd4a6769c98edb3b5f AS build

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



FROM alpine:3.18.5@sha256:34871e7290500828b39e22294660bee86d966bc0017544e848dd9a255cdf59e0

WORKDIR /app

RUN apk update \
	&& apk upgrade -a \
	#&& apk --no-cache add --upgrade busybox ssl_client nodejs-current \
	&& apk --no-cache add --upgrade busybox ssl_client nodejs \
	&& rm -rf /var/cache/apk/*

COPY --from=build /app .

ENTRYPOINT ["node", "cli.js"]

