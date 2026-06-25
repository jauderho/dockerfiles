#FROM rust:bullseye AS build
FROM rust:1.96.0-alpine3.24@sha256:f87aa870663e2b57ec8c69de82c7eedf7383bee987eef7612c0359635eaadb41 AS build
#FROM ghcr.io/jauderho/alpine:3.24.1@sha256:fc6aa8bd54b01bbe7fd9e2d2e79c87837ab82abf83387a0dbb16fb6c7b17997d AS build

WORKDIR /usr/src/github.com/osrg/rustybgp/
#COPY Cargo.toml Cargo.toml

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/osrg/rustybgp/archive/
#ARG GIT_URL=https://github.com/jauderho/rustybgp.git
ARG GIT_URL=https://github.com/osrg/rustybgp.git

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc protoc protobuf-dev git musl-dev mold \
	# Full git clone in order to be able to revert b61f8ac5f8caccef8b145f26c09807eb1df4472f
	&& git clone ${GIT_URL} \
	&& cd /usr/src/github.com/osrg/rustybgp/rustybgp \
	# revert and remove CPU requirement
	#&& git revert -n b61f8ac5f8caccef8b145f26c09807eb1df4472f \
	#&& git reset HEAD . \
	&& rustup component add rustfmt \
	&& RUSTFLAGS="-C link-arg=-fuse-ld=mold" cargo build --release \
	&& strip target/release/rustybgpd

WORKDIR /config


# ----------------------------------------------------------------------------


FROM scratch
#FROM alpine:3.17.2@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a
#FROM debian:11-slim
#FROM rust:bullseye

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/rustybgp"
LABEL org.opencontainers.image.description="A BGP implementation in Rust"

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /usr/src/github.com/osrg/rustybgp/rustybgp/target/release/rustybgpd /usr/local/bin/rustybgpd
COPY --from=build /config /config

#RUN apk update \
#	&& apk add --no-cache dumb-init

USER 1000

#ENTRYPOINT ["dumb-init", "/usr/local/bin/rustybgpd"]
ENTRYPOINT ["/usr/local/bin/rustybgpd"]
#CMD ["--help"]

