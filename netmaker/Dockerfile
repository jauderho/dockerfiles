FROM ghcr.io/jauderho/golang:1.26.2-alpine3.23@sha256:ea32dc6766eace72cd0d7c0723cec2545525380485e5c0117d534887d74aa2d7 AS build

WORKDIR /go/src/github.com/gravitl/netmaker/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/gravitl/netmaker/archive/refs/tags/

ENV CGO_ENABLED=1

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/netmaker.tar.gz \
	&& tar xzf /tmp/netmaker.tar.gz --strip 1 -C /go/src/github.com/gravitl/netmaker \
	&& go get -u github.com/go-jose/go-jose/v3 golang.org/x/net \
	&& go get -u golang.org/x/crypto \
	&& go mod tidy \
	&& CGO_CFLAGS="-D_LARGEFILE64_SOURCE" go build -o ./netmaker -v -trimpath -ldflags="-s -w -X main.version=${BUILD_VERSION}" . 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.23.4@sha256:1c31749c7913a6f917b14f19b2fa6a13891e438ee400d402f9a969fa148192e6

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

