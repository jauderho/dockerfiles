#FROM node:17-alpine3.15@sha256:6f8ae702a7609f6f18d81ac72998e5d6f5d0ace9a13b866318c76340c6d986b2 AS build
FROM alpine:3.16.0@sha256:686d8c9dfa6f3ccfc8230bc3178d23f84eeaf7e457f36f271ab1acc53015037c

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/prettier/prettier/archive/

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
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

