FROM golang:1.19.3-alpine3.17@sha256:8bd8a4b55b233ea77a81250f83637553ef9e3348c5a0cc3ce440c5d45bf7d51d AS build

#COPY . /go/src/github.com/jauderho/bl3auto/
WORKDIR /go/src/github.com/jauderho/bl3auto/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jauderho/bl3auto/archive/

ENV GO111MODULE on

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/bl3auto.tar.gz \
	&& tar xzf /tmp/bl3auto.tar.gz --strip 1 -C /go/src/github.com/jauderho/bl3auto \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w" ./cmd/bl3auto.go

# Validation check
RUN ls -l /go/src/github.com/jauderho/bl3auto
RUN cp bl3auto /go/bin/bl3auto

# ----------------------------------------------------------------------------

#FROM scratch
FROM alpine:3.17.0@sha256:8914eb54f968791faf6a8638949e480fef81e697984fba772b3976835194c6d4

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/bl3auto"
LABEL org.opencontainers.image.description="Borderlands Auto SHiFT Code Redemption System"

COPY --from=build /go/src/github.com/jauderho/bl3auto/bl3auto /usr/local/bin/

# EXPOSE
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
#USER bl3auto

ENTRYPOINT ["/usr/local/bin/bl3auto"]

#CMD ["/usr/local/bin/bl3auto"]
