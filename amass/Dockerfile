FROM ghcr.io/jauderho/golang:1.25.5-alpine3.23@sha256:af19078930f6ab508355e5ed169253d7c862153fe2ccefec67e4eacd3c1d5c84 AS build

WORKDIR /go/src/github.com/owasp/amass/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/owasp/amass/archive/

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc musl-dev \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/amass.tar.gz \
	&& tar xzf /tmp/amass.tar.gz --strip 1 -C /go/src/github.com/owasp/amass \
	&& go get -u github.com/jackc/pgx/v5 google.golang.org/protobuf github.com/golang/glog \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go mod tidy \
	&& go build -v -trimpath -ldflags="-s -w" ./cmd/amass 

WORKDIR /config


# ----------------------------------------------------------------------------


FROM ghcr.io/jauderho/alpine:3.23.3@sha256:350bc73d1a938d40605f8ecd1009be511e61804d8452af018d63b8eac931fe33

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

