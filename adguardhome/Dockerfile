FROM ghcr.io/jauderho/golang:1.23.4-alpine3.21@sha256:210bb8b3c50f280c3143aa09bbca1e5ac3f7a93c94454ca190bda587fc999be7 AS build

WORKDIR /go/src/github.com/adguardteam/adguardhome/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/adguardteam/adguardhome/archive/
ARG GIT_URL=https://github.com/adguardteam/adguardhome.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc musl-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/adguardteam/adguardhome \
	&& cd /go/src/github.com/adguardteam/adguardhome \
	&& go get -u golang.org/x/crypto golang.org/x/net github.com/quic-go/quic-go \
	&& go build -v -trimpath -ldflags="-s -w -X github.com/AdguardTeam/AdGuardHome/internal/version.version=${BUILD_VERSION}" . 


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.21.2@sha256:49660a4a4767aecfe40cd74f1d4b02edf1bc66867c6829beeef0aea87b5b8dd9

ARG BUILD_VERSION

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/adguardhome"
LABEL org.opencontainers.image.description="Network-wide ads & trackers blocking DNS server"

RUN apk update \
	&& apk upgrade -a \
	&& apk --no-cache add ca-certificates libcap tzdata \
	&& mkdir -p /opt/adguardhome/conf /opt/adguardhome/work \
	&& chown -R nobody: /opt/adguardhome

COPY --chown=nobody:nogroup --from=build /go/src/github.com/adguardteam/adguardhome/AdGuardHome /opt/adguardhome/AdGuardHome

RUN setcap 'cap_net_bind_service=+eip' /opt/adguardhome/AdGuardHome

# 53     : TCP, UDP : DNS
# 67     :      UDP : DHCP (server)
# 68     :      UDP : DHCP (client)
# 80     : TCP      : HTTP (main)
# 443    : TCP, UDP : HTTPS, DNS-over-HTTPS (incl. HTTP/3), DNSCrypt (main)
# 853    : TCP, UDP : DNS-over-TLS, DNS-over-QUIC
# 3000   : TCP, UDP : HTTP(S) (alt, incl. HTTP/3)
# 5443   : TCP, UDP : DNSCrypt (alt)
# 6060   : TCP      : HTTP (pprof)
EXPOSE 53/tcp 53/udp 67/udp 68/udp 80/tcp 443/tcp 443/udp 853/tcp\
	853/udp 3000/tcp 3000/udp 5443/tcp 5443/udp 6060/tcp

WORKDIR /opt/adguardhome/work

ADD https://github.com/AdguardTeam/AdGuardHome/releases/download/${BUILD_VERSION}/AdGuardHome_frontend.tar.gz ..

ENTRYPOINT ["/opt/adguardhome/AdGuardHome"]

CMD [ \
	"--no-check-update", \
	"-c", "/opt/adguardhome/conf/AdGuardHome.yaml", \
	"-w", "/opt/adguardhome/work" \
]
