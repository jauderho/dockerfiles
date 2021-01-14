FROM golang:1-alpine as build

#ARG ARCH
#ARG GOARCH
#ARG GOARM
ARG BUILD_VERSION

#WORKDIR /go/src/github.com/cloudflare/cloudflared/cmd/cloudflared

RUN apk update \
	&& apk --no-cache add git gcc build-base \ 
	&& go get -d -v github.com/cloudflare/cloudflared/cmd/cloudflared

WORKDIR /go/src/github.com/cloudflare/cloudflared/cmd/cloudflared

#RUN GOARCH=${GOARCH} GOARM=${GOARM} go build ./
RUN go build ./

#FROM multiarch/alpine:${ARCH}-edge
FROM alpine:latest

LABEL maintainer="Jauder Ho"

ENV DNS1 1.1.1.1
ENV DNS2 1.0.0.1
ENV UPSTREAM1 https://${DNS1}/dns-query
ENV UPSTREAM2 https://${DNS2}/dns-query
ENV PORT 5054
ENV ADDRESS 0.0.0.0
ENV METRICS 127.0.0.1:8080

RUN apk add --no-cache ca-certificates bind-tools libcap \
	&& adduser -S cloudflared \
        && rm -rf /var/cache/apk/*;

COPY --from=build /go/src/github.com/cloudflare/cloudflared/cmd/cloudflared/cloudflared /usr/local/bin/cloudflared

RUN setcap CAP_NET_BIND_SERVICE+eip /usr/local/bin/cloudflared

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s CMD nslookup -po=${PORT} cloudflare.com 127.0.0.1 || exit 1

USER cloudflared

CMD ["/bin/sh", "-c", "/usr/local/bin/cloudflared proxy-dns --address ${ADDRESS} --port ${PORT} --metrics ${METRICS} --upstream ${UPSTREAM1} --upstream ${UPSTREAM2}"]

#CMD ["/bin/sh", "-c", "/usr/local/bin/cloudflared proxy-dns --address 0.0.0.0 --upstream https://1.1.1.1/dns-query --upstream https://1.0.0.1/dns-query"]
