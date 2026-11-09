#FROM alpine:edge@sha256:1a4c2018cfbab67566904e18fde9bf6a5c190605bf7da0e1d181b26746a15188 AS build
#FROM ghcr.io/jauderho/alpine:3.24.4@sha256:835901013b6b16fb72368244b88776efef08c6d56fbc607a3fa8f749d1f7f876 AS build
FROM rust:1.99.1-alpine3.24@sha256:44819b27be4c97b0e4d7203bd2e02c4820f97700211b6a37fb4c246a2de59383 AS build

WORKDIR /usr/src/github.com/getzola/zola/
#COPY Cargo.toml Cargo.toml

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/getzola/zola/archive/

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl openssl-dev openssl-libs-static g++ build-base musl-dev make mold \
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/zola.tar.gz \
	&& tar xzf /tmp/zola.tar.gz --strip 1 -C /usr/src/github.com/getzola/zola \
	&& OPENSSL_STATIC=1 RUSTFLAGS="-C link-arg=-fuse-ld=mold" cargo build --release \
	&& strip target/release/zola

WORKDIR /config


# ----------------------------------------------------------------------------


# Files the alpine base used to provide (and that scratch lacks)
FROM build AS rootfs
RUN mkdir -p -m 1777 /rootfs/tmp


# ----------------------------------------------------------------------------

FROM scratch
#FROM debian:11-slim
#FROM rust:1.70.0-alpine3.18@sha256:74ad9d14ec89bc4e83bf2a3d007fd981513ee4b44279b40d3a90c001a6ca938c

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/zola"
LABEL org.opencontainers.image.description="zola is a fast static site generator in a single binary with everything built-in"

COPY --from=rootfs /rootfs/ /
COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /usr/src/github.com/getzola/zola/target/release/zola /usr/local/bin/zola
COPY --from=build /config /config

#RUN /usr/local/bin/zola --help

USER 1000

ENTRYPOINT ["/usr/local/bin/zola"]
CMD ["--help"]

