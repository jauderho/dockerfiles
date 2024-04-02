#FROM alpine:edge@sha256:1a4c2018cfbab67566904e18fde9bf6a5c190605bf7da0e1d181b26746a15188 AS build
#FROM alpine:3.19.1@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b AS build
FROM rust:1.77.1-alpine3.19@sha256:d4c2b0a1544462f40b6179aedff4f5485a019a213907c8590ed77d1b6145a29c AS build

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
FROM alpine:3.19.1@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b
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

