FROM golang:1.22.1-alpine3.19@sha256:0466223b8544fb7d4ff04748acc4d75a608234bf4e79563bff208d2060c0dd79 AS build

#WORKDIR /go/src/github.com/opentofu/opentofu/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/opentofu/opentofu/archive/
ARG GIT_URL=https://github.com/opentofu/opentofu.git

ENV GO111MODULE on
ENV CGO_ENABLED 1

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc build-base \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/opentofu/opentofu \
	#&& git clone --depth 1 ${GIT_URL} /go/src/github.com/opentofu/opentofu \
	&& cd /go/src/github.com/opentofu/opentofu \
	&& go generate ./... \
	&& go run ./tools/protobuf-compile . \
	&& go build -v -trimpath -ldflags="-s -w -X github.com/opentofu/opentofu/version.dev=no -X main.experimentsAllowed=yes" ./cmd/tofu \
	&& cp tofu /go/bin/tofu \
	&& go clean && go clean -cache && go clean -modcache 



# ----------------------------------------------------------------------------



#FROM scratch
FROM alpine:3.19.1@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/opentofu"
LABEL org.opencontainers.image.description="opentofu is a tool for building, changing, and versioning infrastructure safely and efficiently"

RUN apk update \
	&& apk upgrade -a 

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /go/bin/tofu /usr/local/bin/tofu

#RUN opentofu --version

ENTRYPOINT [ "/usr/local/bin/tofu" ]

