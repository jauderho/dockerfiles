FROM ghcr.io/jauderho/golang:1.27.1-alpine3.24@sha256:f42cbce2b1e4592ed4ac9531589b3730f78be7ad00bb3415268ff0e64569124a AS build

WORKDIR /go/src/github.com/dinedal/textql/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/dinedal/textql/archive/
ARG GIT_URL=https://github.com/dinedal/textql.git

ENV CGO_ENABLED=1

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache git gcc musl-dev sqlite-dev \ 
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/dinedal/textql \
	&& cd /go/src/github.com/dinedal/textql \
	&& CGO_CFLAGS="-D_LARGEFILE64_SOURCE" go build -v -o textql-cli -trimpath -ldflags="-s -w" ./textql

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.2@sha256:d7308a9e8d47ee8ada78214e58040511898720b57f2dd32da2003d41c66a790b

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/textql"
LABEL org.opencontainers.image.description="textql allows you to easily execute SQL against structured text like CSV or TSV"

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache sqlite

COPY --from=build /go/src/github.com/dinedal/textql/textql-cli /usr/local/bin/textql
COPY --from=build /config /config

WORKDIR /tmp

ENTRYPOINT ["/usr/local/bin/textql"]

