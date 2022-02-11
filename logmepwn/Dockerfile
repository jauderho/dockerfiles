FROM golang:1.17.7-alpine3.15@sha256:c23027af83ff27f663d7983750a9a08f442adb2e7563250787b23ab3b6750d9e AS build

WORKDIR /go/src/github.com/0xInfection/logmepwn

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/0xInfection/logmepwn/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl git gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/logmepwn.tar.gz \
	&& tar xzf /tmp/logmepwn.tar.gz --strip 1 -C /go/src/github.com/0xInfection/logmepwn \ 
	&& go build -o lmp -v -trimpath -buildmode=pie -ldflags="-s -w" .

# Validation check
RUN cp lmp /go/bin/lmp



# ----------------------------------------------------------------------------



#FROM scratch
FROM alpine:3.15.0@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/logmepwn"
LABEL org.opencontainers.image.description="logmepwn is a mass scanner for log4shell"

RUN apk add --no-cache ca-certificates \
	&& update-ca-certificates \
  && rm -rf /var/cache/apk/*

COPY --from=build /go/bin/lmp /usr/local/bin

WORKDIR /lmp

ENTRYPOINT ["lmp"]

