FROM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:75f8f4b30907514de96c51f951d84d51160d66fdf51c2e1017e620b8e0207a4a AS build

WORKDIR /go/src/github.com/StackExchange/dnscontrol/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/StackExchange/dnscontrol/archive/

ENV GO111MODULE=on

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc build-base git \
	&& update-ca-certificates \
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/dnscontrol.tar.gz \
	&& tar xzf /tmp/dnscontrol.tar.gz --strip 1 -C /go/src/github.com/StackExchange/dnscontrol \
	&& go build -v -trimpath -ldflags="-s -w -X main.Version=${BUILD_VERSION}" \
	&& cp dnscontrol /go/bin/dnscontrol \
	&& go clean && go clean -cache && go clean -modcache 

# Validation check
RUN dnscontrol version



# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:f310f8a4fad676899731a97c5eaf004c9cb9e822018a2ad7d23c3aeda3a7d773

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

