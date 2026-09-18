FROM ghcr.io/jauderho/golang:1.27.1-alpine3.24@sha256:f42cbce2b1e4592ed4ac9531589b3730f78be7ad00bb3415268ff0e64569124a AS build

#COPY . /go/src/github.com/jauderho/bl3auto/
WORKDIR /go/src/github.com/jauderho/bl3auto/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jauderho/bl3auto/archive/

ENV GO111MODULE=on

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc build-base \
	&& update-ca-certificates \
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/bl3auto.tar.gz \
	&& tar xzf /tmp/bl3auto.tar.gz --strip 1 -C /go/src/github.com/jauderho/bl3auto \
	&& go get -u golang.org/x/net \
	&& go build -v -trimpath -ldflags="-s -w" ./cmd/bl3auto.go

# Validation check
RUN ls -l /go/src/github.com/jauderho/bl3auto
RUN cp bl3auto /go/bin/bl3auto


# ----------------------------------------------------------------------------


FROM ghcr.io/jauderho/alpine:3.24.2@sha256:a1192a21955909e6f8d3ad5fe9b24c5c848c2567809d543e18e09ab68881bfea

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/bl3auto"
LABEL org.opencontainers.image.description="Borderlands Auto SHiFT Code Redemption System"

RUN apk update \
	&& apk upgrade -a

COPY --from=build /go/src/github.com/jauderho/bl3auto/bl3auto /usr/local/bin/

# EXPOSE
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
#USER bl3auto

ENTRYPOINT ["/usr/local/bin/bl3auto"]

#CMD ["/usr/local/bin/bl3auto"]
