# syntax = docker/dockerfile:experimental
# 1st build 
FROM golang:alpine as build

# https://golang.org/doc/install/source#environment
ENV CGO_ENABLED 0
ENV GOOS linux
#ENV GOARCH arm64
ARG VERSION=2.0.39
WORKDIR /go/src/github.com/jedisct1/
RUN --mount=type=cache,target=/root/.cache/go-build \
  apk add --update --no-cache git
RUN git clone -b ${VERSION} --depth=1 https://github.com/jedisct1/dnscrypt-proxy /go/src/github.com/jedisct1/
RUN cd /go/src/github.com/jedisct1/dnscrypt-proxy \
  && go build -v -tags "osusergo netgo" -ldflags '-extldflags "-static -s -w"' -o /go/bin/dnscrypt-proxy

# 2nd build
FROM scratch
LABEL maintainer="kometchtech <kometch@gmail.com>" \
      description="A flexible DNS proxy, with support for modern encrypted DNS protocols \
                  such as DNSCrypt v2 and DNS-over-HTTP/2." \
      url="https://github.com/jedisct1/dnscrypt-proxy"

# Environmet
#ENV TZ Asia/Tokyo

# publish port DNS over UDP & TCP
EXPOSE 53/TCP 53/UDP
#EXPOSE 5300/TCP 5300/UDP

# service running
STOPSIGNAL SIGTERM

# command
CMD [ "dnscrypt-proxy", "-config", "/etc/dnscrypt-proxy/example-dnscrypt-proxy.toml"]

# Multi stage build
WORKDIR /etc/dnscrypt-proxy/
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /go/bin/dnscrypt-proxy /usr/local/bin/
COPY --from=build /go/src/github.com/jedisct1/dnscrypt-proxy/example-* /etc/dnscrypt-proxy/
