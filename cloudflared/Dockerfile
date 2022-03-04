FROM golang:1.17.7-alpine3.15@sha256:d030a987c28ca403007a69af28ba419fca00fc15f08e7801fc8edee77c00b8ee AS build

WORKDIR /go/src/github.com/cloudflare/cloudflared/cmd/cloudflared

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/cloudflare/cloudflared/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl gcc build-base bind-tools libcap \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/cloudflared.tar.gz \
	&& tar xzf /tmp/cloudflared.tar.gz --strip 1 -C /go/src/github.com/cloudflare/cloudflared \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w -X main.Version=${BUILD_VERSION}" \
	&& adduser -S cloudflared \
	&& mkdir /etc/cloudflared

# Validation check
RUN cp cloudflared /go/bin/cloudflared
RUN setcap CAP_NET_BIND_SERVICE+eip /go/bin/cloudflared
RUN cloudflared -v



# ----------------------------------------------------------------------------



#FROM scratch
FROM alpine:3.15.0@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/cloudflared"
LABEL org.opencontainers.image.description="Command line client for Cloudflare's Argo Tunnel"

# Default to Cloudflare and Quad9
ENV DNS1 1.1.1.1
ENV DNS2 9.9.9.9
ENV UPSTREAM1 https://${DNS1}/dns-query
ENV UPSTREAM2 https://${DNS2}/dns-query
ENV PORT 5454
ENV ADDRESS 0.0.0.0
ENV METRICS 127.0.0.1:8888

COPY --from=build /etc/passwd /etc/group /etc/cloudflared /etc/
COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/bin/cloudflared /usr/local/bin/cloudflared

#RUN setcap CAP_NET_BIND_SERVICE+eip /usr/local/bin/cloudflared

# Use alpine as a base image if healthcheck is desired
#HEALTHCHECK --interval=5s --timeout=3s --start-period=5s CMD nslookup -po=${PORT} cloudflare.com 127.0.0.1 || exit 1

USER cloudflared

ENTRYPOINT ["/usr/local/bin/cloudflared"]
CMD ["proxy-dns --address ${ADDRESS} --port ${PORT} --metrics ${METRICS} --upstream ${UPSTREAM1} --upstream ${UPSTREAM2} --no-autoupdate"]

