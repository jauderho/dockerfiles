FROM ghcr.io/jauderho/golang:1.23.1-alpine3.20@sha256:f359bddc4fee0ccaa6ce20e85aa96bb8b4c00382f62ee735c9eecf9897f19c88 AS build

WORKDIR /go/src/github.com/hashicorp/terraform/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/hashicorp/terraform/archive/

ENV GO111MODULE on

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/terraform.tar.gz \
	&& tar xzf /tmp/terraform.tar.gz --strip 1 -C /go/src/github.com/hashicorp/terraform \
	&& go get -u github.com/hashicorp/go-getter github.com/cloudflare/circl google.golang.org/protobuf golang.org/x/net \
	&& go get -u go.opentelemetry.io/otel/sdk/trace \
	&& go mod tidy \
	&& go build -v -trimpath -ldflags="-s -w" \
	&& cp terraform /go/bin/terraform \
	&& go clean && go clean -cache && go clean -modcache 



# ----------------------------------------------------------------------------



#FROM scratch
FROM ghcr.io/jauderho/alpine:3.20.3@sha256:7d51dd030c8c83a805f71a1487c8bc5673771985842515dc468ef52ace748ffe

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/terraform"
LABEL org.opencontainers.image.description="Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently"

RUN apk update \
	&& apk upgrade -a 

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /go/bin/terraform /usr/local/bin/terraform

#RUN terraform --version

ENTRYPOINT [ "/usr/local/bin/terraform" ]

