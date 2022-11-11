FROM golang:1.19.3-alpine3.16@sha256:dc4f4756a4fb91b6f496a958e11e00c0621130c8dfbb31ac0737b0229ad6ad9c AS build

WORKDIR /go/src/github.com/asciimoo/wuzz/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/asciimoo/wuzz/archive/
ARG GIT_URL=https://github.com/jauderho/wuzz.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl git gcc musl-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/asciimoo/wuzz \
	&& cd /go/src/github.com/asciimoo/wuzz \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w" . 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.16.2@sha256:bc41182d7ef5ffc53a40b044e725193bc10142a1243f395ee852a8d9730fc2ad

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/wuzz"
LABEL org.opencontainers.image.description="wuzz is an interactive cli tool for HTTP inspection"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/asciimoo/wuzz/wuzz /usr/local/bin/wuzz
COPY --from=build /config /config

#ENTRYPOINT ["/usr/local/bin/wuzz"]

# wuzz does not want to start up consistently unless sleep 1 is used.It would be better if we could just directly enter into the binary
ENTRYPOINT ["sh", "-c", "sleep 1 ; /usr/local/bin/wuzz"]

