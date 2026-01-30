FROM ubuntu:25.10@sha256:4a9232cc47bf99defcc8860ef6222c99773330367fcecbf21ba2edb0b810a31e AS build
#FROM golang:1.25.3-trixie@sha256:7534a6264850325fcce93e47b87a0e3fddd96b308440245e6ab1325fa8a44c91 AS build

WORKDIR /go/src/github.com/cilium/pwru/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/cilium/pwru/archive/
ARG GIT_URL=https://github.com/cilium/pwru.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apt-get update \
	&& apt-get dist-upgrade -y \
	&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q curl build-essential git ca-certificates llvm-20 clang-20 golang-go gcc flex bison mold \
	#&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q curl build-essential git ca-certificates llvm-17 clang-17 golang-go gcc flex bison mold libdpdk-dev \
	#&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q curl build-essential git ca-certificates llvm-17 clang-17 flex bison \
	&& ln -s /usr/bin/clang-20 /usr/bin/clang \
	&& ln -s /usr/bin/llvm-strip-20 /usr/bin/llvm-strip \
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
FROM ubuntu:25.10@sha256:4a9232cc47bf99defcc8860ef6222c99773330367fcecbf21ba2edb0b810a31e

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/pwru"
LABEL org.opencontainers.image.description="pwru is an eBPF-based tool for tracing network packets in the Linux kernel with advanced filtering capabilities."

RUN apt-get update \
	&& apt-get dist-upgrade -y

COPY --from=build /go/src/github.com/cilium/pwru/pwru /usr/local/bin/pwru
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/pwru"]

