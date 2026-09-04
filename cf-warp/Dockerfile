FROM oven/bun:1.4.1-alpine@sha256:2ef545220f7a886f22fcb3f2309bbd6bcf1c0aa04b7d79c31765c7aa4a13aac1 AS build

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



FROM oven/bun:1.4.1-alpine@sha256:2ef545220f7a886f22fcb3f2309bbd6bcf1c0aa04b7d79c31765c7aa4a13aac1

WORKDIR /app

RUN apk update \
	&& apk upgrade -a \
	&& rm -rf /var/cache/apk/*

COPY --from=build /app .

ENTRYPOINT ["bun", "cli.js"]
