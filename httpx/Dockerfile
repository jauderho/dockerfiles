FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.3-alpine3.24@sha256:eb4fb7ca7697ba2a12c8aa96dab198c419746c269d59a74abc17f53c058a5218 AS build
# Refresh the CA bundle to the latest the distro publishes
RUN apk add --no-cache --upgrade ca-certificates \
	&& update-ca-certificates

WORKDIR /go/src/github.com/projectdiscovery/httpx/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/projectdiscovery/httpx/archive/

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache curl gcc musl-dev \
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/httpx.tar.gz \
	&& tar xzf /tmp/httpx.tar.gz --strip 1 -C /go/src/github.com/projectdiscovery/httpx \
	&& go get -u github.com/quic-go/quic-go \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& GOARM="${TARGETVARIANT#v}" go build -o httpx -v -trimpath -ldflags="-s -w" cmd/httpx/httpx.go 

WORKDIR /config


# ----------------------------------------------------------------------------

# Files the alpine base used to provide (and that scratch lacks)
FROM build AS rootfs
RUN set -e; \
	mkdir -p -m 1777 /rootfs/tmp; \
	mkdir -p -m 700 /rootfs/root/.config


# ----------------------------------------------------------------------------

FROM scratch

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/httpx"
LABEL org.opencontainers.image.description="httpx is a fast and multi-purpose HTTP toolkit"

COPY --from=rootfs /rootfs/ /
COPY --from=build /etc/ssl/certs /etc/ssl/certs

ENV HOME=/root
COPY --from=build /go/src/github.com/projectdiscovery/httpx/httpx /usr/local/bin/httpx
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/httpx"]
#CMD ["-h"]
