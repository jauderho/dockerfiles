#FROM node:21.7.3-alpine3.19@sha256:6d0f18a1c67dc218c4af50c21256616286a53c09e500fadf025b6d342e1c90ae AS build
FROM node:21.7.3-alpine3.19@sha256:6d0f18a1c67dc218c4af50c21256616286a53c09e500fadf025b6d342e1c90ae AS build
#FROM node:18.20.2-alpine3.19@sha256:80338ff3fc4e989c1d5264a23223cec1c6014e812e584e825e78d1a98d893381 AS build

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
	#&& git fetch origin 0a588a880b972f4e2f15e23bc244cce1c1ff2160 \
	#&& git reset --hard 0a588a880b972f4e2f15e23bc244cce1c1ff2160 \
	&& yarn global add -W vite \
	#&& ls -l node_modules/.bin \
	#&& export PATH=./node_modules/.bin:$PATH \
	#&& echo $PATH \
	&& yarn add -W cross-env react react-dom react-scripts eslint postcss \
	&& yarn --ignore-optional --network-timeout 600000 \
	#&& yarn install \
	#&& yarn up \
	#&& yarn up -R eslint postcss react-scripts react react-dom \
	#&& npx browserslist@latest --update-db \
	&& yarn build:app:docker



# ----------------------------------------------------------------------------



# cgr.dev/chainguard/nginx:1.25.1@sha256:183318178aac1c4692a3de76d4fdece9d0c78329a3f91eded9949edbbb27d994
FROM nginx:1.25.5-alpine3.19@sha256:5c3aa130b70df4e6061405b0d81de66a998858a51cf39102d646ac2976bc4690

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
