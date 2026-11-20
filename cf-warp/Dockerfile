FROM oven/bun:1.4.5-alpine@sha256:da816670775f4c2b4e990b6b1847cf5540dcdc721a42033dd331ce7a88ba6a3b AS build

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



FROM oven/bun:1.4.5-alpine@sha256:da816670775f4c2b4e990b6b1847cf5540dcdc721a42033dd331ce7a88ba6a3b

WORKDIR /app

RUN apk update \
	&& apk upgrade -a \
	&& rm -rf /var/cache/apk/*

COPY --from=build /app .

ENTRYPOINT ["bun", "cli.js"]
