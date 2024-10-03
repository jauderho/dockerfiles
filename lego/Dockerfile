FROM ghcr.io/jauderho/golang:1.23.2-alpine3.20@sha256:c57959d750dd3b3a5c8a13c1e1309c24ded2fedcddac73fc339962bbc7911d60 AS build

WORKDIR /go/src/github.com/go-acme/lego/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/go-acme/lego/archive/

ENV GO111MODULE on

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl make git gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/lego.tar.gz \
	&& tar xzf /tmp/lego.tar.gz --strip 1 -C /go/src/github.com/go-acme/lego \
	&& go get -u google.golang.org/grpc google.golang.org/protobuf \
	&& go mod tidy \
	&& make build \
	&& strip /go/src/github.com/go-acme/lego/dist/lego \
	&& cp /go/src/github.com/go-acme/lego/dist/lego /go/src/github.com/go-acme/lego-bin \
	&& make clean 

# ----------------------------------------------------------------------------

FROM scratch

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/lego"
LABEL org.opencontainers.image.description="Let's Encrypt client and ACME library written in Go"

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /go/src/github.com/go-acme/lego-bin /usr/local/bin/lego

#RUN lego --version

ENTRYPOINT [ "/usr/local/bin/lego" ]
