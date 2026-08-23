FROM oven/bun:1.4.0-alpine@sha256:07235578f79ef8c6f97d94aee7938e76f5cdba5f21ae5dbfdd3d3d38058437eb AS build

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



FROM oven/bun:1.4.0-alpine@sha256:07235578f79ef8c6f97d94aee7938e76f5cdba5f21ae5dbfdd3d3d38058437eb

WORKDIR /app

RUN apk update \
	&& apk upgrade -a \
	&& rm -rf /var/cache/apk/*

COPY --from=build /app .

ENTRYPOINT ["bun", "cli.js"]
