#FROM node:20.8-alpine3.18@sha256:37750e51d61bef92165b2e29a77da4277ba0777258446b7a9c99511f119db096 AS build
FROM ghcr.io/jauderho/alpine:3.22.1@sha256:6cedbe16d634f856346fb6224aeddf939413076aaf08bc0216a2ee1759917a56

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/prettier/prettier/archive/

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates nodejs-current npm \
	&& update-ca-certificates \
	&& npm install -g prettier@${BUILD_VERSION} \
	&& npm cache clean --force \
	&& apk del npm

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/prettier"
LABEL org.opencontainers.image.description="prettier is an opinionated code formatter"

WORKDIR /work

ENTRYPOINT ["prettier"]
CMD ["--help"]

