#FROM golang:alpine AS build
FROM golang:alpine@sha256:519c827ec22e5cf7417c9ff063ec840a446cdd30681700a16cf42eb43823e27c AS build

WORKDIR /go/src/github.com/FiloSottile/age/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/FiloSottile/age/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/age.tar.gz \
	&& tar xzf /tmp/age.tar.gz --strip 1 -C /go/src/github.com/FiloSottile/age \
	&& go build -o . -v -trimpath -ldflags="-s -w -X main.Version=${BUILD_VERSION}" filippo.io/age/cmd/... 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.14

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/age"
LABEL org.opencontainers.image.description="age is a simple, modern and secure file encryption tool, format, and Go library"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/FiloSottile/age/age /usr/local/bin/age
COPY --from=build /go/src/github.com/FiloSottile/age/age-keygen /usr/local/bin/age-keygen
COPY --from=build /config /config

CMD ["/usr/local/bin/age"]

