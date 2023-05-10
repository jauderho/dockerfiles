#FROM rust:bullseye AS build
FROM rust:1.69.0-alpine3.17@sha256:a1123af3383f0e71da8deca8afc1e506ff3ee48c7903f253a11b7b632d938190 AS build
#FROM alpine:3.18.0@sha256:02bb6f428431fbc2809c5d1b41eab5a68350194fb508869a33cb1af4444c9b11 AS build

WORKDIR /usr/src/github.com/osrg/rustybgp/
#COPY Cargo.toml Cargo.toml

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/osrg/rustybgp/archive/
ARG GIT_URL=https://github.com/jauderho/rustybgp.git
#ARG GIT_URL=https://github.com/osrg/rustybgp.git

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl gcc protoc git musl-dev mold \
	# Full git clone in order to be able to revert b61f8ac5f8caccef8b145f26c09807eb1df4472f
	&& git clone ${GIT_URL} \
	&& cd /usr/src/github.com/osrg/rustybgp/rustybgp \
	# revert and remove CPU requirement
	&& git revert -n b61f8ac5f8caccef8b145f26c09807eb1df4472f \
	&& git reset HEAD . \
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

