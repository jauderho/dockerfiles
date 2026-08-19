FROM ghcr.io/jauderho/golang:1.26.6-alpine3.24@sha256:e07200aceb844fea2934eeab605e3461b811fe6ebe719ca2d7594111633cdd75 AS build

WORKDIR /go/src/github.com/owasp/amass/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/owasp/amass/archive/

ENV CGO_ENABLED=0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/amass.tar.gz \
	&& tar xzf /tmp/amass.tar.gz --strip 1 -C /go/src/github.com/owasp/amass \
	&& go get -u github.com/jackc/pgx/v5 google.golang.org/protobuf github.com/golang/glog \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& go build -v -trimpath -ldflags="-s -w" ./cmd/amass 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM ghcr.io/jauderho/alpine:3.24.1@sha256:e198ded2ad4e953fa5349cd30f01ff6f7d07773254d079df4aca4a6a2dd24bf5

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/amass"
LABEL org.opencontainers.image.description="amass performs network mapping of attack surfaces and external asset discovery "

RUN apk update \
	&& apk upgrade -a

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/owasp/amass/amass /usr/local/bin/amass
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/amass"]
CMD ["-help"]

