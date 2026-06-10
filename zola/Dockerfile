#FROM alpine:edge@sha256:1a4c2018cfbab67566904e18fde9bf6a5c190605bf7da0e1d181b26746a15188 AS build
#FROM ghcr.io/jauderho/alpine:3.23.4@sha256:e82de71b2f6ff2a9422529e644b3b86d1df91c0c70a3916376af0e67de33b9ce AS build
FROM rust:1.96.0-alpine3.23@sha256:66f48b19d6e88519e2e58bebe0d945779a6a4ca41c2db17db78c9569655b50ac AS build

WORKDIR /usr/src/github.com/getzola/zola/
#COPY Cargo.toml Cargo.toml

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/getzola/zola/archive/

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl openssl-dev g++ build-base musl-dev make mold \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/zola.tar.gz \
	&& tar xzf /tmp/zola.tar.gz --strip 1 -C /usr/src/github.com/getzola/zola \
	&& RUSTFLAGS="-C link-arg=-fuse-ld=mold -C target-feature=-crt-static" cargo build --release \
	&& strip target/release/zola

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.0@sha256:2b33bf7098b70256590a938abfa745b70ba3d8b8f8cce356402e5a92833e4bdd
#FROM debian:11-slim
#FROM rust:1.70.0-alpine3.18@sha256:74ad9d14ec89bc4e83bf2a3d007fd981513ee4b44279b40d3a90c001a6ca938c

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/zola"
LABEL org.opencontainers.image.description="zola is a fast static site generator in a single binary with everything built-in"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /usr/src/github.com/getzola/zola/target/release/zola /usr/local/bin/zola
COPY --from=build /config /config

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache libgcc libstdc++

#RUN /usr/local/bin/zola --help

USER 1000

ENTRYPOINT ["/usr/local/bin/zola"]
CMD ["--help"]

