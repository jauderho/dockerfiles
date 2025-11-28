FROM ghcr.io/jauderho/golang:1.25.4-alpine3.22@sha256:142b9d9f4243eae9f378d0d9b3f1a5ebfd7460721d60ec15345084a187b7d246 AS build
#FROM ghcr.io/jauderho/golang:1.24.5-alpine3.22@sha256:1ee281925d91a253c035e34b04fbb7cd78177933a64432ad868abdf6421ffdbd AS build

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
FROM ghcr.io/jauderho/alpine:3.22.2@sha256:087377192e01c8d243c586c54757ffebfb86928184844df199ceddf8164cba2b

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

