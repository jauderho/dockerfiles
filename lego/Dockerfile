FROM ghcr.io/jauderho/golang:1.27.1-alpine3.24@sha256:c0602f4fc233e306e5a48560962564d65a31c537161ed479c630c99d1d2b9898 AS build

WORKDIR /go/src/github.com/go-acme/lego/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/go-acme/lego/archive/

ENV GO111MODULE=on

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl make git gcc build-base \
	&& update-ca-certificates \
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/lego.tar.gz \
	&& tar xzf /tmp/lego.tar.gz --strip 1 -C /go/src/github.com/go-acme/lego \
	&& go get -u google.golang.org/grpc google.golang.org/protobuf \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& make build \
	&& strip /go/src/github.com/go-acme/lego/dist/lego \
	&& cp /go/src/github.com/go-acme/lego/dist/lego /go/src/github.com/go-acme/lego-bin \
	&& go clean && go clean -cache && go clean -modcache \
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
