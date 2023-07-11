#FROM node:16-alpine3.16@sha256:1908564153449b1c46b329e6ce2307e226bc566294f822f11c5a8bcef4eeaad7 AS build
FROM node:20.4-alpine3.18@sha256:8165161b6e06ec092cf5d02731e8559677644845567dbe41b814086defc8c261 AS build

WORKDIR /app

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/excalidraw/excalidraw/archive/
ARG GIT_URL=https://github.com/excalidraw/excalidraw.git
#ARG GIT_URL=https://github.com/jauderho/excalidraw.git
ARG NODE_ENV=production
ARG NODE_OPTIONS=--openssl-legacy-provider

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates git \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} . \
	&& yarn set version berry \
	&& yarn install \
	&& yarn up \
	&& yarn up -R eslint postcss react-scripts \
	&& npx browserslist@latest --update-db \
	&& yarn build:app:docker



# ----------------------------------------------------------------------------



FROM nginx:1.25.1-alpine@sha256:2d194184b067db3598771b4cf326cfe6ad5051937ba1132b8b7d4b0184e0d0a6

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/excalidraw"
LABEL org.opencontainers.image.description="Excalidraw is a virtual whiteboard for sketching hand-drawn like diagrams."

# temp fix for curl CVEs
RUN apk update \
	&& apk upgrade -a

COPY --from=build /app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
