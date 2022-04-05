#FROM alpine:edge@sha256:1a4c2018cfbab67566904e18fde9bf6a5c190605bf7da0e1d181b26746a15188 AS build
#FROM alpine:3.15.4@sha256:4edbd2beb5f78b1014028f4fbb99f3237d9561100b6881aabbf5acce2c4f9454 AS build
FROM rust:1.59.0-alpine3.15@sha256:6c9887fbc5f23ef7c38b4f5c643a36c4cdd41734418b74a7e6ef295999f016a7 AS build
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
	&& RUSTFLAGS="-C link-arg=-fuse-ld=lld" cargo build --release \
	&& strip target/release/zola

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.15.4@sha256:4edbd2beb5f78b1014028f4fbb99f3237d9561100b6881aabbf5acce2c4f9454
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

