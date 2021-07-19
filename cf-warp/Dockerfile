FROM node:16-alpine3.14 AS build
#FROM node:16-alpine3.14 AS build

WORKDIR /app

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jauderho/cf-warp/archive/

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/cf-warp.tar.gz \
	&& tar xzf /tmp/cf-warp.tar.gz --strip 1 -C /app \
	&& yarn \
	&& yarn outdated

COPY . .

# ----------------------------------------------------------------------------

FROM gcr.io/distroless/nodejs:14
#FROM node:16-alpine

WORKDIR /app
COPY --from=build /app .

ENTRYPOINT ["/nodejs/bin/node", "cli.js"]
#ENTRYPOINT ["node", "cli.js"]
