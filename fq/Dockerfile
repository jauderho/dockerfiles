FROM golang:1.22.1-alpine3.19@sha256:0466223b8544fb7d4ff04748acc4d75a608234bf4e79563bff208d2060c0dd79 AS build

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

