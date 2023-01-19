FROM golang:1.19.5-alpine3.17@sha256:2381c1e5f8350a901597d633b2e517775eeac7a6682be39225a93b22cfd0f8bb AS build

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
FROM alpine:3.17.1@sha256:f271e74b17ced29b915d351685fd4644785c6d1559dd1f2d4189a5e851ef753a

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

