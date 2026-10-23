FROM ghcr.io/jauderho/golang:1.27.3-alpine3.24@sha256:a79e7d5dc64ceb20fdc346d5dcabbbda8c3c8a82e1cc5e087935a0cf407d0f00 AS build

WORKDIR /go/src/github.com/multiprocessio/dsq/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/multiprocessio/dsq/archive/
ARG GIT_URL=https://github.com/multiprocessio/dsq.git

# dsq embeds sqlite through cgo (go-sqlite3 is a stub with CGO_ENABLED=0), so it is
# built natively per platform and linked statically against musl for scratch.
ENV CGO_ENABLED=1

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git gcc musl-dev \ 
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/multiprocessio/dsq \
	&& cd /go/src/github.com/multiprocessio/dsq \
	&& go get -u google.golang.org/protobuf golang.org/x/net \
	&& go get -u github.com/snowflakedb/gosnowflake \
	&& go get -u golang.org/x/crypto golang.org/x/net google.golang.org/grpc github.com/xuri/excelize/v2 \
	&& go mod tidy \
	&& CGO_CFLAGS="-D_LARGEFILE64_SOURCE" go build -v -trimpath -ldflags="-s -w -linkmode external -extldflags '-static'"

WORKDIR /config


# ----------------------------------------------------------------------------

# Files the alpine base used to provide (and that scratch lacks)
FROM build AS rootfs
RUN set -e; \
	mkdir -p -m 1777 /rootfs/tmp


# ----------------------------------------------------------------------------

FROM scratch

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dsq"
LABEL org.opencontainers.image.description="dsq is a CLI companion to DataStation (a GUI) for running SQL queries against data files"

COPY --from=rootfs /rootfs/ /
COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /go/src/github.com/multiprocessio/dsq/dsq /usr/local/bin/dsq
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/dsq"]
