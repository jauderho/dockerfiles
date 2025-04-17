FROM ghcr.io/jauderho/golang:1.24.2-alpine3.21@sha256:59a72c0e0fc4c879bcf803b0eba3ae58fc79c6d7913ddb99bea644468e96461a AS build

WORKDIR /go/src/github.com/0xInfection/logmepwn

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/0xInfection/logmepwn/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/logmepwn.tar.gz \
	&& tar xzf /tmp/logmepwn.tar.gz --strip 1 -C /go/src/github.com/0xInfection/logmepwn \ 
	&& go get -u golang.org/x/crypto golang.org/x/net github.com/valyala/fasthttp \ 
	&& go build -o lmp -v -trimpath -ldflags="-s -w" .

# Validation check
RUN cp lmp /go/bin/lmp



# ----------------------------------------------------------------------------



#FROM scratch
FROM ghcr.io/jauderho/alpine:3.21.3@sha256:4d30faf9002da9de8e2b91f6c1fadd20d55377434596e161fa014a72a3cf4dd1

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/logmepwn"
LABEL org.opencontainers.image.description="logmepwn is a mass scanner for log4shell"

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates \
	&& update-ca-certificates \
	&& rm -rf /var/cache/apk/*

COPY --from=build /go/bin/lmp /usr/local/bin

WORKDIR /lmp

ENTRYPOINT ["lmp"]

