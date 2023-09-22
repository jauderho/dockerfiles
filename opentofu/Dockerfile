FROM golang:1.21.1-alpine3.18@sha256:96634e55b363cb93d39f78fb18aa64abc7f96d372c176660d7b8b6118939d97b AS build

#WORKDIR /go/src/github.com/opentofu/opentofu/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/opentofu/opentofu/archive/
ARG GIT_URL=https://github.com/opentofu/opentofu.git

ENV GO111MODULE on

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc build-base \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/opentofu/opentofu \
	&& cd /go/src/github.com/opentofu/opentofu \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w -X github.com/opentofu/opentofu/version.dev=no -X main.experimentsAllowed=yes" \
	&& cp opentofu /go/bin/opentofu \
	&& go clean && go clean -cache && go clean -modcache 



# ----------------------------------------------------------------------------



#FROM scratch
FROM alpine:3.18.3@sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/opentofu"
LABEL org.opencontainers.image.description="opentofu is a tool for building, changing, and versioning infrastructure safely and efficiently"

RUN apk update \
	&& apk upgrade -a 

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /go/bin/opentofu /usr/local/bin/opentofu

#RUN opentofu --version

ENTRYPOINT [ "/usr/local/bin/opentofu" ]

