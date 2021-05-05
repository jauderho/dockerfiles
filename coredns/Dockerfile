#FROM debian:stable-slim as build
FROM golang:alpine as build

WORKDIR /go/src/github.com/coredns/coredns/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/coredns/coredns/archive/

ENV GO111MODULE on
#ENV CGO_ENABLED 0

ADD . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl make git \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/coredns.tar.gz \
	&& tar xzf /tmp/coredns.tar.gz --strip 1 -C /go/src/github.com/coredns/coredns \
	&& make

#RUN apt-get update \
#    && apt-get -uy upgrade \
#    && apt-get -y install ca-certificates \
#    && update-ca-certificates

# ----------------------------------------------------------------------------

FROM scratch

LABEL org.opencontainers.image.authors "Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url "https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation "https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source "https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title "jauderho/coredns"
LABEL org.opencontainers.image.description "CoreDNS is a DNS server"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/coredns/coredns/coredns /usr/local/bin/
#ADD coredns /coredns

EXPOSE 53/tcp 53/udp
ENTRYPOINT ["/usr/local/bin/coredns"]
