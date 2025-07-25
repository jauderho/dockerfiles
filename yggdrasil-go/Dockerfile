FROM ghcr.io/jauderho/golang:1.24.5-alpine3.22@sha256:b161a1a5aeabb6b5ef08854550dbe9843f3da755440576068a0fab3e0287512a AS build

WORKDIR /go/src/github.com/yggdrasil-network/yggdrasil-go/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/yggdrasil-network/yggdrasil-go/archive/
ARG PKGSRC=github.com/yggdrasil-network/yggdrasil-go/src/version

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/yggdrasil-go.tar.gz \
	&& tar xzf /tmp/yggdrasil-go.tar.gz --strip 1 -C /go/src/github.com/yggdrasil-network/yggdrasil-go \
	&& go get -u golang.org/x/tools \
	#&& go get -u github.com/quic-go/quic-go \
	#&& go get -u all \
	&& go mod tidy \
	&& go build -o ./yggdrasil -v -trimpath -ldflags="-s -w -X ${PKGSRC}.buildName=yggdrasil -X ${PKGSRC}.buildVersion=${BUILD_VERSION}" ./cmd/yggdrasil \
	&& go build -o ./yggdrasilctl -v -trimpath -ldflags="-s -w -X ${PKGSRC}.buildName=yggdrasil -X ${PKGSRC}.buildVersion=${BUILD_VERSION}" ./cmd/yggdrasilctl \
	&& go build -o ./genkeys -v -trimpath -ldflags="-s -w -X ${PKGSRC}.buildName=yggdrasil -X ${PKGSRC}.buildVersion=${BUILD_VERSION}" ./cmd/genkeys/main.go

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.17.2@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a

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

