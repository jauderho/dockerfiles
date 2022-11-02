FROM golang:1.19.3-alpine3.16@sha256:8558ae624304387d18694b9ea065cc9813dd4f7f9bd5073edb237541f2d0561b AS build

WORKDIR /go/src/github.com/yggdrasil-network/yggdrasil-go/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/yggdrasil-network/yggdrasil-go/archive/
ARG PKGSRC=github.com/yggdrasil-network/yggdrasil-go/src/version

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/yggdrasil-go.tar.gz \
	&& tar xzf /tmp/yggdrasil-go.tar.gz --strip 1 -C /go/src/github.com/yggdrasil-network/yggdrasil-go \
	&& go build -o ./yggdrasil -v -trimpath -ldflags="-s -w -X ${PKGSRC}.buildName=yggdrasil -X ${PKGSRC}.buildVersion=${BUILD_VERSION}" ./cmd/yggdrasil \
	&& go build -o ./yggdrasilctl -v -trimpath -ldflags="-s -w -X ${PKGSRC}.buildName=yggdrasil -X ${PKGSRC}.buildVersion=${BUILD_VERSION}" ./cmd/yggdrasilctl \
	&& go build -o ./genkeys -v -trimpath -ldflags="-s -w -X ${PKGSRC}.buildName=yggdrasil -X ${PKGSRC}.buildVersion=${BUILD_VERSION}" ./cmd/genkeys/main.go

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.16.2@sha256:bc41182d7ef5ffc53a40b044e725193bc10142a1243f395ee852a8d9730fc2ad

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/yggdrasil-go"
LABEL org.opencontainers.image.description="yggdrasil is an implementation of a fully end-to-end encrypted network"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/yggdrasil-network/yggdrasil-go/yggdrasil /usr/local/bin/yggdrasil
COPY --from=build /go/src/github.com/yggdrasil-network/yggdrasil-go/yggdrasilctl /usr/local/bin/yggdrasilctl
COPY --from=build /go/src/github.com/yggdrasil-network/yggdrasil-go/genkeys /usr/local/bin/genkeys
COPY --from=build /config /config

CMD ["/usr/local/bin/yggdrasil"]

