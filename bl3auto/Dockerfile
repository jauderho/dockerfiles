#FROM golang:1.18.1-alpine3.15@sha256:42d35674864fbb577594b60b84ddfba1be52b4d4298c961b46ba95e9fb4712e8 AS build
FROM golang:1.18.1-alpine3.15@sha256:42d35674864fbb577594b60b84ddfba1be52b4d4298c961b46ba95e9fb4712e8 AS build

#COPY . /go/src/github.com/jauderho/bl3auto/
WORKDIR /go/src/github.com/jauderho/bl3auto/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jauderho/bl3auto/archive/

ENV GO111MODULE on

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/bl3auto.tar.gz \
	&& tar xzf /tmp/bl3auto.tar.gz --strip 1 -C /go/src/github.com/jauderho/bl3auto \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w" ./cmd/bl3auto.go

# Validation check
RUN ls -l /go/src/github.com/jauderho/bl3auto
RUN cp bl3auto /go/bin/bl3auto

# ----------------------------------------------------------------------------

#FROM scratch
FROM alpine:3.15.4@sha256:4edbd2beb5f78b1014028f4fbb99f3237d9561100b6881aabbf5acce2c4f9454

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/bl3auto"
LABEL org.opencontainers.image.description="Borderlands Auto SHiFT Code Redemption System"

COPY --from=build /go/src/github.com/jauderho/bl3auto/bl3auto /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/bl3auto"]

#CMD ["/usr/local/bin/bl3auto"]
