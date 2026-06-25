FROM ghcr.io/jauderho/golang:1.26.4-alpine3.24@sha256:3db9e8c899b9a4a571f7af1c5ca8c2fb2e5f5abaf0190f08e15ab70520116586 AS build

WORKDIR /go/src/github.com/adguardteam/adguardhome/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/adguardteam/adguardhome/archive/
ARG GIT_URL=https://github.com/adguardteam/adguardhome.git

ENV CGO_ENABLED=0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc musl-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/adguardteam/adguardhome \
	&& cd /go/src/github.com/adguardteam/adguardhome \
	# The web UI is embedded into the binary at compile time via //go:embed build.
	# A fresh clone ships an empty build/ dir, so fetch the prebuilt frontend and
	# extract it into build/ before "go build" or the UI renders a blank screen.
	&& curl -fsSL https://github.com/AdguardTeam/AdGuardHome/releases/download/${BUILD_VERSION}/AdGuardHome_frontend.tar.gz \
		| tar xzf - -C /go/src/github.com/adguardteam/adguardhome \
	&& test -f /go/src/github.com/adguardteam/adguardhome/build/static/index.html \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& go build -v -trimpath -ldflags="-s -w -X github.com/AdguardTeam/AdGuardHome/internal/version.version=${BUILD_VERSION}" . \
	&& cp AdGuardHome /go/bin/AdGuardHome \
	&& go clean && go clean -cache && go clean -modcache 


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:fc6aa8bd54b01bbe7fd9e2d2e79c87837ab82abf83387a0dbb16fb6c7b17997d

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

#COPY --chown=nobody:nogroup --from=build /go/src/github.com/adguardteam/adguardhome/AdGuardHome /opt/adguardhome/AdGuardHome
COPY --chown=nobody:nogroup --from=build /go/bin/AdGuardHome /opt/adguardhome/AdGuardHome

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

ENTRYPOINT ["/opt/adguardhome/AdGuardHome"]

CMD [ \
	"--no-check-update", \
	"-c", "/opt/adguardhome/conf/AdGuardHome.yaml", \
	"-w", "/opt/adguardhome/work" \
]
