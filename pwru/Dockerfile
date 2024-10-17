#FROM ubuntu:24.10@sha256:3f49af910ce126ee3d7d1982fe57e34cc90265cb9ac2db3f9e7166e2c21fdb44 AS build
FROM golang:1.23.2-bookworm@sha256:61d20f7495202dde19415ae06b5aff019afa447a7775415b901b3587a51ff04a AS build

WORKDIR /go/src/github.com/cilium/pwru/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/cilium/pwru/archive/
ARG GIT_URL=https://github.com/cilium/pwru.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apt-get update \
	&& apt-get dist-upgrade -y \
	&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q curl build-essential git ca-certificates llvm-16 clang-16 golang-go gcc flex bison mold \
	#&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q curl build-essential git ca-certificates llvm-16 clang-16 flex bison libdpdk-dev \
	#&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q curl build-essential git ca-certificates llvm-16 clang-16 flex bison \
	&& ln -s /usr/bin/clang-16 /usr/bin/clang \
	&& ln -s /usr/bin/llvm-strip-16 /usr/bin/llvm-strip \
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
FROM ubuntu:24.10@sha256:3f49af910ce126ee3d7d1982fe57e34cc90265cb9ac2db3f9e7166e2c21fdb44

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

