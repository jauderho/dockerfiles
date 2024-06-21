#FROM node:20-alpine3.19@sha256:fac6f741d51194c175c517f66bc3125588313327ad7e0ecd673e161e4fa807f3 AS build
FROM node:22-alpine3.20@sha256:df46071ae175bc2c0468ae58e32f00ed6c9779eb70112cdf0d2ccf85035bc7ff AS build

#WORKDIR /app
WORKDIR /opt/node_app

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/excalidraw/excalidraw/archive/
#ARG GIT_URL=https://github.com/excalidraw/excalidraw.git
ARG GIT_URL=https://github.com/jauderho/excalidraw.git
#ARG NODE_ENV=production
#ARG NODE_OPTIONS=--openssl-legacy-provider

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates git \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} .
	#&& git clone --depth 1 ${GIT_URL} . \
	#&& yarn set version berry \
	#&& git fetch origin 0a588a880b972f4e2f15e23bc244cce1c1ff2160 \
	#&& git reset --hard 0a588a880b972f4e2f15e23bc244cce1c1ff2160 \
	#&& yarn global add -W vite \
	#&& ls -l node_modules/.bin \
	#&& export PATH=./node_modules/.bin:$PATH \
	#&& echo $PATH \
	#&& yarn add -W cross-env react react-dom react-scripts eslint postcss \
	#&& yarn --network-timeout 600000 \
	#&& yarn install \
	#&& yarn up \
	#&& yarn up -R eslint postcss react-scripts react react-dom \
	#&& yarn add -W eslint postcss react-scripts react react-dom vite-plugin-react \
	#&& npx update-browserslist-db@latest \
	#&& yarn build:app:docker
	#&& yarn --cwd ./excalidraw-app build:app:docker

RUN yarn --network-timeout 600000

ARG NODE_ENV=production

RUN yarn build:app:docker



# ----------------------------------------------------------------------------



# cgr.dev/chainguard/nginx:1.25.1@sha256:183318178aac1c4692a3de76d4fdece9d0c78329a3f91eded9949edbbb27d994
FROM nginx:1.27.0-alpine3.19@sha256:5c0c2272256857e486cf9fe2983db41c0e14c72476f5ebedf474289fd9ca8627

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
COPY --from=build /opt/node_app/excalidraw-app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
