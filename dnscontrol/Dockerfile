FROM ghcr.io/jauderho/golang:1.24.1-alpine3.21@sha256:6d162053b9471746bdf1d9000d6116d9f7269a648f97e1b15cc3fdcf6c469738 AS build

WORKDIR /go/src/github.com/StackExchange/dnscontrol/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/StackExchange/dnscontrol/archive/

ENV GO111MODULE on

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc build-base git \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/dnscontrol.tar.gz \
	&& tar xzf /tmp/dnscontrol.tar.gz --strip 1 -C /go/src/github.com/StackExchange/dnscontrol \
	&& go build -v -trimpath -ldflags="-s -w -X main.Version=${BUILD_VERSION}" \
	&& cp dnscontrol /go/bin/dnscontrol \
	&& go clean && go clean -cache && go clean -modcache 

# Validation check
RUN dnscontrol version



# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.21.3@sha256:8139b5dd95ef46202c45b611a4b7e972defda480df2e058b95b6a07b4f2e96c4

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dnscontrol"
LABEL org.opencontainers.image.description="DNSControl is an opinionated platform for seamlessly managing your DNS configuration"

RUN apk update \
	&& apk upgrade -a

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /go/bin/dnscontrol /usr/local/bin

WORKDIR /dns

ENTRYPOINT ["/usr/local/bin/dnscontrol"]
CMD ["-h"]

