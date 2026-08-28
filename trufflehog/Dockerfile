FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:29b7407729696dfe1c74c9682a5f33c3b81f4f19be6c689bcb405c85381881ac AS build

WORKDIR /go/src/github.com/trufflesecurity/trufflehog/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/trufflesecurity/trufflehog/archive/

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
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/trufflehog.tar.gz \
	&& tar xzf /tmp/trufflehog.tar.gz --strip 1 -C /go/src/github.com/trufflesecurity/trufflehog \
	&& go get -u google.golang.org/grpc github.com/Azure/go-ntlmssp \
	&& go mod tidy \
	&& GOARM="${TARGETVARIANT#v}" go build -o ./trufflehog -v -trimpath -ldflags="-s -w -X main.Version=${BUILD_VERSION}" .

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:17182a5a7a7f13026b02c689a3605b3f4f1eaf743b4c1fc9fbbc23ba80b34b38

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/trufflehog"
LABEL org.opencontainers.image.description="trufflehog finds leaked credentials"

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/trufflesecurity/trufflehog/trufflehog /usr/local/bin/trufflehog
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/trufflehog"]

