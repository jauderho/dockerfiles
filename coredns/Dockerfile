FROM golang:1.18.4-alpine3.16@sha256:46f1fa18ca1ec228f7ea4978ad717f0a8c5e51436e7b8efaf64011f7729886df AS build

WORKDIR /go/src/github.com/coredns/coredns/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/coredns/coredns/archive/

ENV GO111MODULE on

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl make git gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/coredns.tar.gz \
	&& tar xzf /tmp/coredns.tar.gz --strip 1 -C /go/src/github.com/coredns/coredns \
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
