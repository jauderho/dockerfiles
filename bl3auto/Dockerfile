FROM ghcr.io/jauderho/golang:1.22.5-alpine3.20@sha256:42b7c5450e3cbda706037f99f39b8796a40762a1da28261557d1b9bc48a55c88 AS build

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


FROM ghcr.io/jauderho/alpine:3.20.1@sha256:35bd39e08ef27d15c99521e02fcd1a10ae282d63624f58cfca0f9154749e2c11

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
