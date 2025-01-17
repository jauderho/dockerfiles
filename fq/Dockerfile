FROM ghcr.io/jauderho/golang:1.23.5-alpine3.21@sha256:17c572a41e4d236d72a1fab8b4e04751a46fc3239a225c3fac7d2b41b84a339b AS build

WORKDIR /go/src/github.com/wader/fq

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/wader/fq/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/fq.tar.gz \
	&& tar xzf /tmp/fq.tar.gz --strip 1 -C /go/src/github.com/wader/fq \ 
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go build -o fq -v -trimpath -ldflags="-s -w -X main.version=${BUILD_VERSION}" .

# Validation check
RUN cp fq /go/bin/fq



# ----------------------------------------------------------------------------



FROM scratch
#FROM alpine:3.15.0

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/fq"
LABEL org.opencontainers.image.description="fq is a tool for inspecting binary data"

COPY --from=build /go/bin/fq /fq

ENTRYPOINT ["/fq"]

