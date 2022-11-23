#FROM alpine:3.17.0@sha256:8914eb54f968791faf6a8638949e480fef81e697984fba772b3976835194c6d4 AS build
FROM rust:1.65.0-alpine3.16@sha256:9aa6c9c3df9cfa2f8c5a648a8f1baf8fac31fc5fc7e916389296df92daccf388 AS build

WORKDIR /usr/src/github.com/aramperes/onetun/
#COPY Cargo.toml Cargo.toml

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/aramperes/onetun/archive/

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl lld g++ musl-dev \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/onetun.tar.gz \
	&& tar xzf /tmp/onetun.tar.gz --strip 1 -C /usr/src/github.com/aramperes/onetun \
	&& RUSTFLAGS="-C link-arg=-fuse-ld=lld" cargo build --release \
	&& strip target/release/onetun

WORKDIR /config


# ----------------------------------------------------------------------------


#FROM scratch
FROM alpine:3.17.0@sha256:8914eb54f968791faf6a8638949e480fef81e697984fba772b3976835194c6d4

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

