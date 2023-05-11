FROM golang:1.20.4-alpine3.18@sha256:ee2f23f1a612da71b8a4cd78fec827f1e67b0a8546a98d257cca441a4ddbebcb AS build

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
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w -X main.SHA=${BUILD_VERSION}"

# Validation check
RUN cp dnscontrol /go/bin/dnscontrol
RUN dnscontrol version

#RUN go build -v -trimpath -buildmode=pie -ldflags="-s -w" -o cmd/convertzone/convertzone cmd/convertzone/main.go
#RUN cp cmd/convertzone/convertzone /go/bin/convertzone

# ----------------------------------------------------------------------------

#FROM scratch
FROM alpine:3.18.0@sha256:02bb6f428431fbc2809c5d1b41eab5a68350194fb508869a33cb1af4444c9b11

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
#COPY --from=build /go/bin/convertzone /usr/local/bin

WORKDIR /dns

ENTRYPOINT ["/usr/local/bin/dnscontrol"]
#CMD ["/usr/local/bin/dnscontrol"]
CMD ["-h"]

