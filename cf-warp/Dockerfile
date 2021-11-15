FROM node:17-alpine3.14 AS build

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



FROM node:17-alpine3.14

WORKDIR /app
COPY --from=build /app .

# Fix security issues with base image
RUN yarn upgrade --latest \
	&& yarn upgrade ansi-regex@5.0.1 \
	&& yarn upgrade cookie@0.4.1

RUN apk update \
	&& apk upgrade --no-cache busybox ssl_client

ENTRYPOINT ["node", "cli.js"]
