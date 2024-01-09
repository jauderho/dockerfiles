FROM node:21.5-alpine3.19@sha256:82c93cef3d2acbb2557c5fda48214fbc2bf5385edfb4d96d990690d75ddabf7b AS build
#FROM node:21.4-alpine3.18@sha256:9bfaec4816d320226b1533abd5d22d6a888105ee502b820676736de99a198408 AS build

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
	&& yarn install cross-env \
	&& yarn up \
	&& yarn up -R eslint postcss react-scripts \
	&& npx browserslist@latest --update-db \
	&& yarn build:app:docker



# ----------------------------------------------------------------------------



# cgr.dev/chainguard/nginx:1.25.1@sha256:183318178aac1c4692a3de76d4fdece9d0c78329a3f91eded9949edbbb27d994
FROM nginx:1.25.3-alpine3.18@sha256:a59278fd22a9d411121e190b8cec8aa57b306aa3332459197777583beb728f59

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
