FROM golang:1.19.3-alpine3.16@sha256:dc4f4756a4fb91b6f496a958e11e00c0621130c8dfbb31ac0737b0229ad6ad9c AS build

WORKDIR /go/src/github.com/go-acme/lego/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/go-acme/lego/archive/

ENV GO111MODULE on

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl make git gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/lego.tar.gz \
	&& tar xzf /tmp/lego.tar.gz --strip 1 -C /go/src/github.com/go-acme/lego \
	&& make build

# ----------------------------------------------------------------------------

FROM scratch

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/lego"
LABEL org.opencontainers.image.description="Let's Encrypt client and ACME library written in Go"

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /go/src/github.com/go-acme/lego/dist/lego /usr/local/bin/lego

#RUN lego --version

ENTRYPOINT [ "/usr/local/bin/lego" ]
