#FROM alpine:3.17.2@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a AS build
FROM rust:1.80.0-alpine3.20@sha256:596c7fa13f7458097b8c88ad83f33420da0341e2f5b544e34d9aa18a22fe11d0 AS build

WORKDIR /usr/src/github.com/aramperes/onetun/
#COPY Cargo.toml Cargo.toml

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/aramperes/onetun/archive/

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl lld g++ musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/onetun.tar.gz \
	&& tar xzf /tmp/onetun.tar.gz --strip 1 -C /usr/src/github.com/aramperes/onetun \
	&& RUSTFLAGS="-C link-arg=-fuse-ld=lld" cargo build --release \
	&& strip target/release/onetun

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.20.2@sha256:6f037df56ca0bf09c6854daa341457f5105b1f2ec73b52bc5090026770feb1be

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/onetun"
LABEL org.opencontainers.image.description="A cross-platform, user-space WireGuard port-forwarder that requires no system network configurations."

RUN apk update \
	&& apk upgrade -a

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /usr/src/github.com/aramperes/onetun/target/release/onetun /usr/local/bin/onetun
COPY --from=build /config /config

#RUN apk update \
#	&& apk add --no-cache dumb-init

USER 1000

ENTRYPOINT ["/usr/local/bin/onetun"]
CMD ["--help"]

