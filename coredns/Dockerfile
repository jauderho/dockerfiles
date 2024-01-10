FROM golang:1.21.6-alpine3.19@sha256:fd78f2fb1e49bcf343079bbbb851c936a18fc694df993cbddaa24ace0cc724c5 AS build
#FROM golang:1.21.5-alpine3.19@sha256:4db4aac30880b978cae5445dd4a706215249ad4f43d28bd7cdf7906e9be8dd6b AS build

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
