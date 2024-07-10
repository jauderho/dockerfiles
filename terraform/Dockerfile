FROM golang:1.22.5-alpine3.20@sha256:8c9183f715b0b4eca05b8b3dbf59766aaedb41ec07477b132ee2891ac0110a07 AS build

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
FROM alpine:3.20.1@sha256:b89d9c93e9ed3597455c90a0b88a8bbb5cb7188438f70953fede212a0c4394e0

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

