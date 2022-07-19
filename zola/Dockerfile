#FROM alpine:edge@sha256:1a4c2018cfbab67566904e18fde9bf6a5c190605bf7da0e1d181b26746a15188 AS build
#FROM alpine:3.16.0@sha256:686d8c9dfa6f3ccfc8230bc3178d23f84eeaf7e457f36f271ab1acc53015037c AS build
#FROM rust:1.60.0-alpine3.15@sha256:b38a9e55db25b29d9320c7e04f2ddd688ac68b8582adb3070230d3b7d2f183ae AS build
FROM rust:1.62.0-alpine3.16@sha256:bba9abe20fd21457f264bdf2cef499ce8834e85be52ae4fbfc1e44f64af98f6c AS build
#FROM rust:1.58.1@sha256:e4979d36d5d30838126ea5ef05eb59c4c25ede7f064985e676feb21402d0661b AS build

WORKDIR /usr/src/github.com/getzola/zola/
#COPY Cargo.toml Cargo.toml

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/getzola/zola/archive/

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl openssl-dev lld g++ cargo musl-dev make \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/zola.tar.gz \
	&& tar xzf /tmp/zola.tar.gz --strip 1 -C /usr/src/github.com/getzola/zola \
	&& RUSTFLAGS="-C link-arg=-fuse-ld=lld" cargo build -j1 --release \
	&& strip target/release/zola

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.16.0@sha256:686d8c9dfa6f3ccfc8230bc3178d23f84eeaf7e457f36f271ab1acc53015037c
#FROM debian:11-slim
#FROM rust:1.58.1@sha256:e4979d36d5d30838126ea5ef05eb59c4c25ede7f064985e676feb21402d0661b

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/zola"
LABEL org.opencontainers.image.description="zola is a fast static site generator in a single binary with everything built-in"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /usr/src/github.com/getzola/zola/target/release/zola /usr/local/bin/zola
COPY --from=build /config /config

#RUN apk update \
#	&& apk add --no-cache dumb-init

#RUN /usr/local/bin/zola --help

USER 1000

ENTRYPOINT ["/usr/local/bin/zola"]
CMD ["--help"]

