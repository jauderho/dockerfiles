FROM ghcr.io/jauderho/golang:1.23.4-alpine3.21@sha256:210bb8b3c50f280c3143aa09bbca1e5ac3f7a93c94454ca190bda587fc999be7 AS build

WORKDIR /go/src/github.com/cloudflare/cloudflared/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/cloudflare/cloudflared/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc build-base bind-tools libcap \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/cloudflared.tar.gz \
	&& tar xzf /tmp/cloudflared.tar.gz --strip 1 -C /go/src/github.com/cloudflare/cloudflared \
	&& go get -u github.com/cloudflare/circl github.com/go-jose/go-jose/v3 github.com/quic-go/quic-go google.golang.org/protobuf \
	&& go get -u github.com/coredns/coredns \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& go mod vendor \
	&& go build -o cloudflared -v -trimpath -ldflags="-s -w -X main.Version=${BUILD_VERSION}" ./cmd/cloudflared/ \
	&& adduser -S cloudflared \
	&& mkdir /etc/cloudflared

# Validation check
#RUN cp cloudflared /go/bin/cloudflared
#RUN setcap CAP_NET_BIND_SERVICE+eip cloudflared
RUN ./cloudflared -v



# ----------------------------------------------------------------------------



#FROM scratch
FROM ghcr.io/jauderho/alpine:3.21.2@sha256:49660a4a4767aecfe40cd74f1d4b02edf1bc66867c6829beeef0aea87b5b8dd9

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/cloudflared"
LABEL org.opencontainers.image.description="Command line client for Cloudflare's Argo Tunnel"

RUN apk update \
	&& apk upgrade -a

COPY --from=build /etc/passwd /etc/group /etc/cloudflared /etc/
COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/cloudflared

#RUN setcap CAP_NET_BIND_SERVICE+eip /usr/local/bin/cloudflared

# EXPOSE
# Default to Cloudflare and Quad9
ENV DNS1 1.1.1.1
ENV DNS2 9.9.9.9
ENV UPSTREAM1 https://${DNS1}/dns-query
ENV UPSTREAM2 https://${DNS2}/dns-query
ENV PORT 5454
ENV ADDRESS 0.0.0.0
ENV METRICS 127.0.0.1:8888
# STOPSIGNAL
HEALTHCHECK NONE
#HEALTHCHECK --interval=5s --timeout=3s --start-period=5s CMD nslookup -po=${PORT} cloudflare.com 127.0.0.1 || exit 1
USER cloudflared

ENTRYPOINT ["/usr/local/bin/cloudflared"]
CMD ["proxy-dns --address ${ADDRESS} --port ${PORT} --metrics ${METRICS} --upstream ${UPSTREAM1} --upstream ${UPSTREAM2} --no-autoupdate"]

