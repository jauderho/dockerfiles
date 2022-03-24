FROM node:17-alpine3.15@sha256:6f8ae702a7609f6f18d81ac72998e5d6f5d0ace9a13b866318c76340c6d986b2 AS build
#FROM node:17-alpine3.15 AS build

WORKDIR /app

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jauderho/cf-warp/archive/

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
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
FROM alpine:3.15.2@sha256:ceeae2849a425ef1a7e591d8288f1a58cdf1f4e8d9da7510e29ea829e61cf512

WORKDIR /app
COPY --from=build /app .

RUN apk update \
	&& apk --no-cache add --upgrade busybox ssl_client nodejs

ENTRYPOINT ["node", "cli.js"]
