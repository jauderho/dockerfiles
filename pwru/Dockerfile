FROM ubuntu:23.10@sha256:282510723f2be541c2facce0f7e918641bedd90936f8a76f6f38b7110e299d5c AS build
#FROM golang:1.21.0-bookworm@sha256:640f192f24852cd875514e18a01977ae87692dca466abed7705ad3c4670b6993 AS build

WORKDIR /go/src/github.com/cilium/pwru/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/cilium/pwru/archive/
ARG GIT_URL=https://github.com/cilium/pwru.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apt-get update \
	&& apt-get dist-upgrade -y \
	&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q curl build-essential git ca-certificates llvm-17 clang-17 golang-go gcc flex bison \
	&& ln -s /usr/bin/clang-17 /usr/bin/clang \
	&& ln -s /usr/bin/llvm-strip-17 /usr/bin/llvm-strip \
	#&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/cilium/pwru \
	&& git clone --depth 1 ${GIT_URL} /go/src/github.com/cilium/pwru \
	&& cd /go/src/github.com/cilium/pwru \
	&& cd libpcap \
	&& ./configure --disable-rdma --disable-shared --disable-usb --disable-netmap --disable-bluetooth --disable-dbus --without-libnl \
	&& make \
	&& cd .. \
	&& go generate `uname -m` \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w -X github.com/cilium/pwru/internal/pwru.Version=${BUILD_VERSION}" 

WORKDIR /config



# ----------------------------------------------------------------------------



#FROM scratch
FROM ubuntu:23.10@sha256:282510723f2be541c2facce0f7e918641bedd90936f8a76f6f38b7110e299d5c

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

