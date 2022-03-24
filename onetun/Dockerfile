#FROM alpine:3.15.2@sha256:66b861b1099af1551a0eee163c175fd008744192c3fbb7f22e998db0ce09e8ea AS build
FROM rust:1.59.0-alpine3.15@sha256:3a7c0c5f4608611efaca3b7bba5b01b257312a25823aa50800cbeb18d4f0c92a AS build

WORKDIR /usr/src/github.com/aramperes/onetun/
#COPY Cargo.toml Cargo.toml

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/aramperes/onetun/archive/

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl lld g++ cargo musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/onetun.tar.gz \
	&& tar xzf /tmp/onetun.tar.gz --strip 1 -C /usr/src/github.com/aramperes/onetun \
	&& RUSTFLAGS="-C link-arg=-fuse-ld=lld" cargo build --release \
	&& strip target/release/onetun

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.15.2@sha256:ceeae2849a425ef1a7e591d8288f1a58cdf1f4e8d9da7510e29ea829e61cf512

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/onetun"
LABEL org.opencontainers.image.description="A cross-platform, user-space WireGuard port-forwarder that requires no system network configurations."

COPY --from=build /etc/ssl/certs /etc/ssl/certs

COPY --from=build /usr/src/github.com/aramperes/onetun/target/release/onetun /usr/local/bin/onetun
COPY --from=build /config /config

#RUN apk update \
#	&& apk add --no-cache dumb-init

USER 1000

ENTRYPOINT ["/usr/local/bin/onetun"]
CMD ["--help"]

