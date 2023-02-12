#FROM node:17-alpine3.15@sha256:6f8ae702a7609f6f18d81ac72998e5d6f5d0ace9a13b866318c76340c6d986b2 AS build
FROM alpine:3.17.2@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/prettier/prettier/archive/

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates nodejs npm \
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

