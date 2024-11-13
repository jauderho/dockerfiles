FROM node:23.1-alpine3.20@sha256:340cd3926b5116aae1207d6ca1e444d1009aad687c4ad37aa3afbe8a3db591d5 AS build

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

#RUN yarn outdated
RUN yarn upgrade
RUN yarn --network-timeout 600000

ARG NODE_ENV=production

RUN yarn build:app:docker



# ----------------------------------------------------------------------------



# cgr.dev/chainguard/nginx:1.25.1@sha256:183318178aac1c4692a3de76d4fdece9d0c78329a3f91eded9949edbbb27d994
FROM nginx:1.27.2-alpine3.20@sha256:d44ffb126f474dfbe8b729d4a984d8d798110637560a8db41979461db6f761d2

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
