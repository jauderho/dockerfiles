FROM golang:1.22.1-alpine3.19@sha256:0466223b8544fb7d4ff04748acc4d75a608234bf4e79563bff208d2060c0dd79 AS build

#COPY . /go/src/github.com/jauderho/bl3auto/
WORKDIR /go/src/github.com/jauderho/bl3auto/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jauderho/bl3auto/archive/

ENV GO111MODULE on

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/bl3auto.tar.gz \
	&& tar xzf /tmp/bl3auto.tar.gz --strip 1 -C /go/src/github.com/jauderho/bl3auto \
	&& go build -v -trimpath -ldflags="-s -w" ./cmd/bl3auto.go

# Validation check
RUN ls -l /go/src/github.com/jauderho/bl3auto
RUN cp bl3auto /go/bin/bl3auto


# ----------------------------------------------------------------------------


FROM alpine:3.19.1@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b

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
