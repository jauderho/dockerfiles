#FROM node:17-alpine3.15@sha256:6f8ae702a7609f6f18d81ac72998e5d6f5d0ace9a13b866318c76340c6d986b2 AS build
FROM node:19.5-alpine3.17@sha256:4619ec6c9a43ab4edfa12cf96745319c3ca43aff9dd630ab20e684dd3632318e AS build

WORKDIR /app

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jauderho/cf-warp/archive/

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/cf-warp.tar.gz \
	&& tar xzf /tmp/cf-warp.tar.gz --strip 1 -C /app \
	&& yarn install \
	&& yarn upgrade --latest \
	&& yarn --ignore-optional \
	&& yarn outdated

COPY . .



# ----------------------------------------------------------------------------



#FROM node:17-alpine3.15
FROM alpine:3.17.1@sha256:f271e74b17ced29b915d351685fd4644785c6d1559dd1f2d4189a5e851ef753a

WORKDIR /app
COPY --from=build /app .

RUN apk update \
	&& apk upgrade -a \
	&& apk --no-cache add --upgrade busybox ssl_client nodejs \
	&& rm -rf /var/cache/apk/*

ENTRYPOINT ["node", "cli.js"]

