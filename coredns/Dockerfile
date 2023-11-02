FROM golang:1.21.3-alpine3.18@sha256:96a8a701943e7eabd81ebd0963540ad660e29c3b2dc7fb9d7e06af34409e9ba6 AS build
#FROM golang:1.21.3-alpine3.18@sha256:96a8a701943e7eabd81ebd0963540ad660e29c3b2dc7fb9d7e06af34409e9ba6 AS build

WORKDIR /go/src/github.com/coredns/coredns/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/coredns/coredns/archive/

ENV GO111MODULE on

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl make git gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/coredns.tar.gz \
	&& tar xzf /tmp/coredns.tar.gz --strip 1 -C /go/src/github.com/coredns/coredns \
	&& go get -u golang.org/x/net \
	&& go mod tidy \
	&& make

# Validation check
RUN cp coredns /go/bin/coredns
RUN coredns -version


# ----------------------------------------------------------------------------


FROM scratch

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/coredns"
LABEL org.opencontainers.image.description="CoreDNS is a DNS server"

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /go/src/github.com/coredns/coredns/coredns /usr/local/bin/

#EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/usr/local/bin/coredns"]
