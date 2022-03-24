FROM golang:1.18.0-alpine3.15@sha256:9ccb0ed869157f3b1630f5dda3422b5974defa9dd82c7375ca68dc3a9cbf8fae AS build

WORKDIR /go/src/github.com/hashicorp/terraform/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/hashicorp/terraform/archive/

ENV GO111MODULE on

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates bash curl make git gcc build-base musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/terraform.tar.gz \
	&& tar xzf /tmp/terraform.tar.gz --strip 1 -C /go/src/github.com/hashicorp/terraform \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w"

# ----------------------------------------------------------------------------

#FROM scratch
FROM alpine:3.15.2@sha256:ceeae2849a425ef1a7e591d8288f1a58cdf1f4e8d9da7510e29ea829e61cf512

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/terraform"
LABEL org.opencontainers.image.description="Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently"

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /go/src/github.com/hashicorp/terraform/terraform /usr/local/bin/terraform

#RUN terraform --version

ENTRYPOINT [ "/usr/local/bin/terraform" ]
