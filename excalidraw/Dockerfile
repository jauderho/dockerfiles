#FROM node:21.6-alpine3.19@sha256:4cc2d9f365691fc6f8fe227321d32d9a2691216a71f51c21c7f02224515dea48 AS build
FROM node:21.7-alpine3.19@sha256:4999fa1391e09259e71845d3d0e9ddfe5f51ab30253c8b490c633f710c7446a0 AS build

#WORKDIR /app
WORKDIR /opt/node_app

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
	#&& yarn set version berry \
	&& yarn --ignore-optional --network-timeout 600000 \
	&& yarn add -W cross-env react react-dom \
	#&& yarn install \
	#&& yarn up \
	#&& yarn up -R eslint postcss react-scripts react react-dom \
	#&& npx browserslist@latest --update-db \
	&& yarn build:app:docker



# ----------------------------------------------------------------------------



# cgr.dev/chainguard/nginx:1.25.1@sha256:183318178aac1c4692a3de76d4fdece9d0c78329a3f91eded9949edbbb27d994
FROM nginx:1.25.4-alpine3.18@sha256:02d8d94023878cedf3e3acc55372932a9ba1478b6e2f3357786d916c2af743ba

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/excalidraw"
LABEL org.opencontainers.image.description="Excalidraw is a virtual whiteboard for sketching hand-drawn like diagrams."

# temp fix for curl CVEs
RUN apk update \
	&& apk upgrade -a

#COPY --from=build /app/build /usr/share/nginx/html
COPY --from=build /opt/node_app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
