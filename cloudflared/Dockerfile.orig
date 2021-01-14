ARG ARCH
FROM golang:alpine as gobuild

ARG GOARCH
ARG GOARM

RUN apk update; \
	apk add git;\ 
	go get -v github.com/cloudflare/cloudflared/cmd/cloudflared
WORKDIR /go/src/github.com/cloudflare/cloudflared/cmd/cloudflared
RUN GOARCH=${GOARCH} GOARM=${GOARM} go build ./

FROM multiarch/alpine:${ARCH}-edge

LABEL maintainer="Jauder Ho"

RUN apk add --no-cache ca-certificates; \
        rm -rf /var/cache/apk/*;

COPY --from=gobuild /go/src/github.com/cloudflare/cloudflared/cmd/cloudflared/cloudflared /usr/local/bin/cloudflared

CMD ["/bin/sh", "-c", "/usr/local/bin/cloudflared proxy-dns --address 0.0.0.0 --upstream https://1.1.1.1/dns-query --upstream https://1.0.0.1/dns-query"]
