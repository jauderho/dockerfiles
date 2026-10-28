FROM ghcr.io/jauderho/golang:1.27.3-alpine3.24@sha256:912bbb72c34b2da5574157e979ed57dca24dfad4d39f87e19df0db3b6c2008c6 AS build

WORKDIR /go/src/github.com/StackExchange/dnscontrol/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/StackExchange/dnscontrol/archive/

ENV GO111MODULE=on
ENV CGO_ENABLED=0

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc build-base git \
	&& update-ca-certificates \
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/dnscontrol.tar.gz \
	&& tar xzf /tmp/dnscontrol.tar.gz --strip 1 -C /go/src/github.com/StackExchange/dnscontrol \
	&& go build -v -trimpath -ldflags="-s -w -X github.com/DNSControl/dnscontrol/v5/pkg/version.version=${BUILD_VERSION}" \
	&& cp dnscontrol /go/bin/dnscontrol \
	&& go clean && go clean -cache && go clean -modcache 

# Validation check
# Assert the version ldflag actually landed. The symbol path carries the module
# major version, so it must be bumped in step with BUILD_VERSION (v5 -> v6 ...).
RUN dnscontrol version | grep -q "${BUILD_VERSION}"


# ----------------------------------------------------------------------------

# Files the alpine base used to provide (and that scratch lacks)
FROM build AS rootfs
RUN set -e; \
	apk add --no-cache tzdata; \
	mkdir -p -m 1777 /rootfs/tmp; \
	mkdir -p /rootfs/usr/share && cp -a /usr/share/zoneinfo /rootfs/usr/share/zoneinfo


# ----------------------------------------------------------------------------

FROM scratch

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dnscontrol"
LABEL org.opencontainers.image.description="DNSControl is an opinionated platform for seamlessly managing your DNS configuration"

COPY --from=rootfs /rootfs/ /

# tzdata is a runtime dependency of Go time for some providers (eg TRANSIP)

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /go/bin/dnscontrol /usr/local/bin/dnscontrol

WORKDIR /dns

ENTRYPOINT ["/usr/local/bin/dnscontrol"]
CMD ["-h"]
