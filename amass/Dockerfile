FROM golang:1.20.2-alpine3.17@sha256:e03044ec19ae333714d136a9c8ec2d47330e2b3ac74b7c0303d9e780387e60fa AS build

WORKDIR /go/src/github.com/owasp/amass/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/owasp/amass/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/amass.tar.gz \
	&& tar xzf /tmp/amass.tar.gz --strip 1 -C /go/src/github.com/owasp/amass \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w" ./cmd/amass 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM alpine:3.17.3@sha256:124c7d2707904eea7431fffe91522a01e5a861a624ee31d03372cc1d138a3126

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

