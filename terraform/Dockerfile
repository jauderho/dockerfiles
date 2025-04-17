#FROM ghcr.io/jauderho/golang:1.24.2-alpine3.21@sha256:59a72c0e0fc4c879bcf803b0eba3ae58fc79c6d7913ddb99bea644468e96461a AS build
FROM golang:1.23-alpine3.21 AS build

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
	#&& go get -u github.com/hashicorp/go-getter github.com/cloudflare/circl google.golang.org/protobuf golang.org/x/net \
	#&& go get -u go.opentelemetry.io/otel/sdk/trace \
	&& go mod tidy \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& go build -v -trimpath -ldflags="-s -w" \
	&& cp terraform /go/bin/terraform \
	&& go clean && go clean -cache && go clean -modcache 



# ----------------------------------------------------------------------------



#FROM scratch
FROM ghcr.io/jauderho/alpine:3.21.3@sha256:6140157579a734c234937ab0e8465075a69dbb138c019ed50f229546401a485f

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

