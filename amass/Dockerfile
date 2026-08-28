FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:29b7407729696dfe1c74c9682a5f33c3b81f4f19be6c689bcb405c85381881ac AS build

WORKDIR /go/src/github.com/owasp/amass/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/owasp/amass/archive/

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
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/amass.tar.gz \
	&& tar xzf /tmp/amass.tar.gz --strip 1 -C /go/src/github.com/owasp/amass \
	&& go get -u github.com/jackc/pgx/v5 google.golang.org/protobuf github.com/golang/glog \
	&& go get -u golang.org/x/crypto golang.org/x/net google.golang.org/grpc \
	&& go mod tidy \
	&& GOARM="${TARGETVARIANT#v}" go build -v -trimpath -ldflags="-s -w" ./cmd/amass 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM ghcr.io/jauderho/alpine:3.24.1@sha256:f310f8a4fad676899731a97c5eaf004c9cb9e822018a2ad7d23c3aeda3a7d773

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/amass"
LABEL org.opencontainers.image.description="amass performs network mapping of attack surfaces and external asset discovery "

RUN apk update \
	&& apk upgrade -a

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/owasp/amass/amass /usr/local/bin/amass
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/amass"]
CMD ["-help"]

