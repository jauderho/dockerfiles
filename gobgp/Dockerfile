FROM ghcr.io/jauderho/golang:1.24.5-alpine3.22@sha256:b161a1a5aeabb6b5ef08854550dbe9843f3da755440576068a0fab3e0287512a AS build

WORKDIR /go/src/github.com/osrg/gobgp/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/osrg/gobgp/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/gobgp.tar.gz \
	&& tar xzf /tmp/gobgp.tar.gz --strip 1 -C /go/src/github.com/osrg/gobgp \
	&& go get -u golang.org/x/net \
	&& go mod tidy \
	&& go build -v -trimpath -ldflags="-s -w" ./cmd/gobgp/ \
	&& go build -v -trimpath -ldflags="-s -w" ./cmd/gobgpd/ 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/gobgp"
LABEL org.opencontainers.image.description="GoBGP is an open source BGP implementation"

COPY --from=build /etc/passwd /etc/group /etc/
COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/osrg/gobgp/gobgp /usr/local/bin/
COPY --from=build /go/src/github.com/osrg/gobgp/gobgpd /usr/local/bin/
COPY --from=build --chown=nobody:nogroup /config /config

EXPOSE 179
USER nobody

#ENTRYPOINT ["/usr/local/bin/gobgpd"]
#CMD ["-f", "/config/gobgp.toml"]

CMD ["/usr/local/bin/gobgpd", "-f", "/config/gobgp.toml"]
