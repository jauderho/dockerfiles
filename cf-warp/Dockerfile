FROM oven/bun:1.3.14-alpine@sha256:5acc90a93e91ff07bf72aa90a7c9f0fa189765aec90b47bdbf2152d2196383c0 AS build

WORKDIR /app

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jauderho/cf-warp/archive/

ADD "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" /tmp/cf-warp.tar.gz

# The tarball ships the workspace manifests + single bun.lock; --filter limits
# the install to the cf-warp CLI package so the web member's deps (express,
# etc.) are skipped.
RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& tar xzf /tmp/cf-warp.tar.gz --strip 1 -C /app \
	&& rm /tmp/cf-warp.tar.gz \
	&& bun install --frozen-lockfile --production --filter cf-warp



# ----------------------------------------------------------------------------



FROM oven/bun:1.3.14-alpine@sha256:5acc90a93e91ff07bf72aa90a7c9f0fa189765aec90b47bdbf2152d2196383c0

WORKDIR /app

RUN apk update \
	&& apk upgrade -a \
	&& rm -rf /var/cache/apk/*

COPY --from=build /app .

ENTRYPOINT ["bun", "cli.js"]
