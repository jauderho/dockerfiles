FROM node@sha256:6f8ae702a7609f6f18d81ac72998e5d6f5d0ace9a13b866318c76340c6d986b2 AS build
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
FROM alpine@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300

WORKDIR /app
COPY --from=build /app .

#RUN apk update \
#	&& apk --no-cache add --upgrade busybox ssl_client nodejs

ENTRYPOINT ["node", "cli.js"]
