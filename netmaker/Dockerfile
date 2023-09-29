FROM golang:1.21.1-alpine3.18@sha256:1c9cc949513477766da12bfa80541c4f24957323b0ee00630a6ff4ccf334b75b AS build

WORKDIR /go/src/github.com/gravitl/netmaker/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/gravitl/netmaker/archive/refs/tags/

ENV CGO_ENABLED 1

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/netmaker.tar.gz \
	&& tar xzf /tmp/netmaker.tar.gz --strip 1 -C /go/src/github.com/gravitl/netmaker \
	&& go build -o ./netmaker -v -trimpath -buildmode=pie -ldflags="-s -w -X main.version=${BUILD_VERSION}" . 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.18.4@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/netmaker"
LABEL org.opencontainers.image.description="Netmaker automates fast, secure, and distributed virtual networks using Wireguard"

RUN apk update \
	&& apk upgrade -a \
	&& apk --no-cache add gcompat iptables

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/gravitl/netmaker/netmaker /usr/local/bin/netmaker
COPY --from=build /config /config

EXPOSE 8081
EXPOSE 50051

ENTRYPOINT ["/usr/local/bin/netmaker"]
CMD ["help"]

