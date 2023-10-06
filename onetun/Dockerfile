#FROM alpine:3.17.2@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a AS build
FROM rust:1.73.0-alpine3.18@sha256:7113e385cdcbd4e491ffc26d7bc3e321f9a7f0155c7e60904c7f854f5572ae6a AS build

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
FROM alpine:3.18.4@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978

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

