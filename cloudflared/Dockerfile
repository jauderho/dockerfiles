FROM golang:1.21.6-alpine3.19@sha256:fd78f2fb1e49bcf343079bbbb851c936a18fc694df993cbddaa24ace0cc724c5 AS build

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
	&& go get -u github.com/cloudflare/circl \
	&& go mod vendor \
	&& go build -o cloudflared -v -trimpath -buildmode=pie -ldflags="-s -w -X main.Version=${BUILD_VERSION}" ./cmd/cloudflared/ \
	&& adduser -S cloudflared \
	&& mkdir /etc/cloudflared

# Validation check
#RUN cp cloudflared /go/bin/cloudflared
#RUN setcap CAP_NET_BIND_SERVICE+eip cloudflared
RUN ./cloudflared -v



# ----------------------------------------------------------------------------



#FROM scratch
FROM alpine:3.19.0@sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48

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

