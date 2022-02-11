FROM golang:1.17.7-alpine3.15@sha256:c23027af83ff27f663d7983750a9a08f442adb2e7563250787b23ab3b6750d9e AS build

WORKDIR /go/src/github.com/wader/fq

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/wader/fq/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
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

