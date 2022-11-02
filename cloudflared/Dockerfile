#FROM golang:1.19.3-alpine3.16@sha256:8558ae624304387d18694b9ea065cc9813dd4f7f9bd5073edb237541f2d0561b AS build
FROM golang:1.19.3-alpine3.16@sha256:8558ae624304387d18694b9ea065cc9813dd4f7f9bd5073edb237541f2d0561b AS build

WORKDIR /go/src/github.com/cloudflare/cloudflared/

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
	&& go build -o cloudflared -v -trimpath -buildmode=pie -ldflags="-s -w -X main.Version=${BUILD_VERSION}" ./cmd/cloudflared/ \
	&& adduser -S cloudflared \
	&& mkdir /etc/cloudflared

# Validation check
#RUN cp cloudflared /go/bin/cloudflared
#RUN setcap CAP_NET_BIND_SERVICE+eip cloudflared
RUN ./cloudflared -v



# ----------------------------------------------------------------------------



#FROM scratch
FROM alpine:3.16.2@sha256:bc41182d7ef5ffc53a40b044e725193bc10142a1243f395ee852a8d9730fc2ad

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/cloudflared"
LABEL org.opencontainers.image.description="Command line client for Cloudflare's Argo Tunnel"

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

