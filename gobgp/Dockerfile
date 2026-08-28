FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:29b7407729696dfe1c74c9682a5f33c3b81f4f19be6c689bcb405c85381881ac AS build

WORKDIR /go/src/github.com/osrg/gobgp/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/osrg/gobgp/archive/

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/gobgp.tar.gz \
	&& tar xzf /tmp/gobgp.tar.gz --strip 1 -C /go/src/github.com/osrg/gobgp \
	&& go get -u golang.org/x/net \
	&& go mod tidy \
	&& GOARM="${TARGETVARIANT#v}" go build -v -trimpath -ldflags="-s -w" ./cmd/gobgp/ \
	&& GOARM="${TARGETVARIANT#v}" go build -v -trimpath -ldflags="-s -w" ./cmd/gobgpd/ 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/gobgp"
LABEL org.opencontainers.image.description="GoBGP is an open source BGP implementation"

COPY --from=build /etc/passwd /etc/group /etc/
COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/osrg/gobgp/gobgp /usr/local/bin/
COPY --from=build /go/src/github.com/osrg/gobgp/gobgpd /usr/local/bin/
COPY --from=build --chown=nobody:nogroup /config /config

EXPOSE 179
USER nobody

#ENTRYPOINT ["/usr/local/bin/gobgpd"]
#CMD ["-f", "/config/gobgp.toml"]

CMD ["/usr/local/bin/gobgpd", "-f", "/config/gobgp.toml"]
