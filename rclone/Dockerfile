FROM --platform=$BUILDPLATFORM ghcr.io/jauderho/golang:1.27.3-alpine3.24@sha256:26ea163201120d1548e20ff90cc7de11370900aaeb97ea3971799ed0205fc7c0 AS build

WORKDIR /go/src/github.com/rclone/rclone/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/rclone/rclone/archive/

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
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/rclone.tar.gz \
	&& tar xzf /tmp/rclone.tar.gz --strip 1 -C /go/src/github.com/rclone/rclone \
	&& go get -u golang.org/x/net \
	&& go get -u golang.org/x/crypto golang.org/x/net golang.org/x/image \
	&& go mod tidy \
	&& GOARM="${TARGETVARIANT#v}" go build -o rclone -v -trimpath -ldflags="-s -w" 

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.4@sha256:835901013b6b16fb72368244b88776efef08c6d56fbc607a3fa8f749d1f7f876

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/rclone"
LABEL org.opencontainers.image.description="rclone is a cli app to sync files and dirs between cloud providers"

RUN apk update \
	&& apk upgrade -a \
	&& apk --no-cache add ca-certificates fuse tzdata \
	&& echo "user_allow_other" >> /etc/fuse.conf \
	&& addgroup -g 1009 rclone \
	&& adduser -u 1009 -Ds /bin/sh -G rclone rclone

COPY --from=build /go/src/github.com/rclone/rclone/rclone /usr/local/bin/rclone
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/rclone"]

