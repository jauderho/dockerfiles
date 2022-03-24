FROM golang:1.18.0-alpine3.15@sha256:e83afef7ceae1953ec8d92ad10bf4971f74b7c6b2224d025e36d1c06ccd0c813 AS build

WORKDIR /go/src/github.com/StackExchange/dnscontrol/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/StackExchange/dnscontrol/archive/

ENV GO111MODULE on

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl gcc build-base git \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/dnscontrol.tar.gz \
	&& tar xzf /tmp/dnscontrol.tar.gz --strip 1 -C /go/src/github.com/StackExchange/dnscontrol \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w"

# Validation check
RUN cp dnscontrol /go/bin/dnscontrol
RUN dnscontrol version

RUN go build -v -trimpath -buildmode=pie -ldflags="-s -w" -o cmd/convertzone/convertzone cmd/convertzone/main.go
RUN cp cmd/convertzone/convertzone /go/bin/convertzone

# ----------------------------------------------------------------------------

#FROM scratch
FROM alpine:3.15.2@sha256:66b861b1099af1551a0eee163c175fd008744192c3fbb7f22e998db0ce09e8ea

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dnscontrol"
LABEL org.opencontainers.image.description="DNSControl is an opinionated platform for seamlessly managing your DNS configuration"

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /go/bin/dnscontrol /usr/local/bin
COPY --from=build /go/bin/convertzone /usr/local/bin

WORKDIR /dns

#ENTRYPOINT ["/usr/local/bin/dnscontrol"]
CMD ["/usr/local/bin/dnscontrol"]
