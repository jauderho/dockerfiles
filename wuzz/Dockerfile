FROM golang:1.20.2-alpine3.17@sha256:576da1aa73f8ffa3dc6a7577b6032bd834aa84f2e1714d3e7e96b06b49f4e177 AS build

WORKDIR /go/src/github.com/asciimoo/wuzz/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/asciimoo/wuzz/archive/
ARG GIT_URL=https://github.com/jauderho/wuzz.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc musl-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/asciimoo/wuzz \
	&& cd /go/src/github.com/asciimoo/wuzz \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w" . 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.17.2@sha256:ff6bdca1701f3a8a67e328815ff2346b0e4067d32ec36b7992c1fdc001dc8517

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/wuzz"
LABEL org.opencontainers.image.description="wuzz is an interactive cli tool for HTTP inspection"

RUN apk update \
	&& apk upgrade -a 

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/asciimoo/wuzz/wuzz /usr/local/bin/wuzz
COPY --from=build /config /config

#ENTRYPOINT ["/usr/local/bin/wuzz"]

# wuzz does not want to start up consistently unless sleep 1 is used.It would be better if we could just directly enter into the binary
ENTRYPOINT ["sh", "-c", "sleep 1 ; /usr/local/bin/wuzz"]

