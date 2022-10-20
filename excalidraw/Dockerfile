#FROM node:16-alpine3.16@sha256:1908564153449b1c46b329e6ce2307e226bc566294f822f11c5a8bcef4eeaad7 AS build
FROM node:19-alpine3.16@sha256:48e43334c84762aa05c18dac37ec5ca396e9d55c5cb053f15cd4edbfe89a0914 AS build

WORKDIR /app

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/excalidraw/excalidraw/archive/
ARG GIT_URL=https://github.com/excalidraw/excalidraw.git
#ARG GIT_URL=https://github.com/jauderho/excalidraw.git
ARG NODE_ENV=production
ARG NODE_OPTIONS=--openssl-legacy-provider

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates git \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} . \
	&& yarn set version berry \
	&& yarn install \
	&& yarn up -R eslint postcss react-scripts \
	&& npx browserslist@latest --update-db

COPY . .
RUN yarn build:app:docker



# ----------------------------------------------------------------------------



FROM nginx:1.23.2-alpine@sha256:bffb4330be734e3268087e28ca51f6ae926f7d4406c7f5b5ab50c5e22570dc32

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/excalidraw"
LABEL org.opencontainers.image.description="Excalidraw is a virtual whiteboard for sketching hand-drawn like diagrams."

# temp fix for curl CVEs
RUN apk update && apk upgrade -a

COPY --from=build /app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
