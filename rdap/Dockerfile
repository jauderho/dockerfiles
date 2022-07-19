FROM golang:1.18.4-alpine3.16@sha256:46f1fa18ca1ec228f7ea4978ad717f0a8c5e51436e7b8efaf64011f7729886df AS build

WORKDIR /go/src/github.com/openrdap/rdap/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/openrdap/rdap/archive/
ARG GIT_URL=https://github.com/jauderho/rdap.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache git ca-certificates \ 
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/openrdap/rdap \
	&& cd /go/src/github.com/openrdap/rdap \
	&& go build -o rdap -v -trimpath -ldflags="-s -w" ./cmd/rdap

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.16.1@sha256:7580ece7963bfa863801466c0a488f11c86f85d9988051a9f9c68cb27f6b7872

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/rdap"
LABEL org.opencontainers.image.description="OpenRDAP is an command line RDAP client implementation in Go"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/openrdap/rdap/rdap /usr/local/bin/rdap
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/rdap"]

