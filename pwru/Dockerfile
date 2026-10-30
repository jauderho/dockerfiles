# Go comes from the base image, not from Debian's golang-go. Ubuntu 26.04 ships
# go1.26.0, which is affected by CVE-2026-27140 and CVE-2026-27143 (fixed in
# 1.26.2). clang-19 matches what pwru's own release Makefile uses.
FROM golang:1.27.3-trixie@sha256:fbb7ae40b62ff8afe31662df570d39b4f5052ac32b90dae8e60d7657a20a74f4 AS build
#FROM ubuntu:26.04@sha256:da6fc2be547864451aa253836dd926da33623312df4a9a243e35dc877c378a78 AS build

WORKDIR /go/src/github.com/cilium/pwru/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/cilium/pwru/archive/
ARG GIT_URL=https://github.com/cilium/pwru.git

ENV CGO_ENABLED=0

RUN test -n "${BUILD_VERSION}" \
	&& apt-get update \
	&& apt-get dist-upgrade -y \
	&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q curl build-essential git ca-certificates llvm-19 clang-19 gcc flex bison mold \
	#&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q curl build-essential git ca-certificates llvm-17 clang-17 golang-go gcc flex bison mold libdpdk-dev \
	#&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q curl build-essential git ca-certificates llvm-17 clang-17 flex bison \
	&& ln -s /usr/bin/clang-19 /usr/bin/clang \
	&& ln -s /usr/bin/llvm-strip-19 /usr/bin/llvm-strip \
	#&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/cilium/pwru \
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/cilium/pwru \
	&& cd /go/src/github.com/cilium/pwru \
	&& go get -u golang.org/x/net \
	&& go mod vendor \
	&& go mod tidy \
	&& make
	#&& cd libpcap \
	#&& ./configure --disable-rdma --disable-shared --disable-usb --disable-netmap --disable-bluetooth --disable-dbus --without-libnl \
	#&& make \
	#&& cd .. \
	#&& go generate `uname -m` \
	#&& go build -v -trimpath -ldflags="-s -w -X github.com/cilium/pwru/internal/pwru.Version=${BUILD_VERSION}" 

WORKDIR /config



# ----------------------------------------------------------------------------



#FROM scratch
FROM ubuntu:26.10@sha256:262df65c0ec6bf8d9dcc87454f4330a05fae4b97825f45854af3b136666584c2

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/pwru"
LABEL org.opencontainers.image.description="pwru is an eBPF-based tool for tracing network packets in the Linux kernel with advanced filtering capabilities."

RUN apt-get update \
	&& apt-get dist-upgrade -y \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates \
	&& rm -rf /usr/bin/pebble \
	# the package index apt-get update wrote is ~40MB and is dead weight once
	# dist-upgrade has run; nothing in this image installs packages at runtime
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean

COPY --from=build /go/src/github.com/cilium/pwru/pwru /usr/local/bin/pwru
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/pwru"]

