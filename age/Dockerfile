FROM golang:1.20.0-alpine3.17@sha256:1e2917143ce7e7bf8d1add2ac5c5fa3d358b2b5ddaae2bd6f54169ce68530ef0 AS build

WORKDIR /go/src/github.com/FiloSottile/age/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/FiloSottile/age/archive/
ARG GIT_URL=https://github.com/FiloSottile/age.git

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc musl-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/FiloSottile/age \
	&& cd /go/src/github.com/FiloSottile/age \
	&& go build -o . -v -trimpath -ldflags="-s -w -X main.Version=${BUILD_VERSION}" filippo.io/age/cmd/... 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/age"
LABEL org.opencontainers.image.description="age is a simple, modern and secure file encryption tool, format, and Go library"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/FiloSottile/age/age /usr/local/bin/age
COPY --from=build /go/src/github.com/FiloSottile/age/age-keygen /usr/local/bin/age-keygen
COPY --from=build /config /config

# EXPOSE
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
# USER

CMD ["/usr/local/bin/age"]
