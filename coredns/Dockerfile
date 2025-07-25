FROM ghcr.io/jauderho/golang:1.24.5-alpine3.22@sha256:b161a1a5aeabb6b5ef08854550dbe9843f3da755440576068a0fab3e0287512a AS build

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
	&& go get -u golang.org/x/crypto golang.org/x/net google.golang.org/grpc google.golang.org/protobuf \
	#&& go get -u github.com/quic-go/quic-go \
	&& go mod tidy \
	&& make \
	&& cp coredns /go/bin/coredns \
	&& go clean && go clean -cache && go clean -modcache

# Validation check
RUN /go/bin/coredns -version



# ----------------------------------------------------------------------------



FROM scratch

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/coredns"
LABEL org.opencontainers.image.description="CoreDNS is a DNS server"

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /go/bin/coredns /usr/local/bin/

#EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/usr/local/bin/coredns"]
