FROM golang:1-alpine as build

WORKDIR /go/src/github.com/StackExchange/dnscontrol/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/StackExchange/dnscontrol/archive/

ENV GO111MODULE on

ADD . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl \
	&& curl -L "${ARCHIVE_URL}v${BUILD_VERSION}.tar.gz" -o /tmp/dnscontrol.tar.gz \
	&& tar xzf /tmp/dnscontrol.tar.gz --strip 1 -C /go/src/github.com/StackExchange/dnscontrol \
	&& go build -v -ldflags="-s -w"

RUN cp dnscontrol /go/bin/dnscontrol
RUN dnscontrol version

RUN go build -v -o cmd/convertzone/convertzone cmd/convertzone/main.go
RUN cp cmd/convertzone/convertzone /go/bin/convertzone

# ----------------------------------------------------------------------------

FROM alpine

RUN apk add --no-cache ca-certificates

COPY --from=build /go/bin/dnscontrol /usr/local/bin
COPY --from=build /go/bin/convertzone /usr/local/bin

WORKDIR /dns

#RUN dnscontrol version
RUN ["dnscontrol", "version"]

CMD dnscontrol
