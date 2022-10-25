FROM ubuntu:22.10@sha256:4f9ec2c0aa321966bfe625bc485aa1d6e96549679cfdf98bb404dfcb8e141a7f AS build

WORKDIR /go/src/github.com/cilium/pwru/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/cilium/pwru/archive/
ARG GIT_URL=https://github.com/cilium/pwru.git

ENV CGO_ENABLED 0

RUN test -n "${BUILD_VERSION}" \
	&& apt-get update \
	&& apt-get dist-upgrade -y \
	&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q git ca-certificates llvm-14 clang-14 golang-go gcc \
	&& ln -s /usr/bin/clang-14 /usr/bin/clang \
	&& ln -s /usr/bin/llvm-strip-14 /usr/bin/llvm-strip \
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/cilium/pwru \
	&& cd /go/src/github.com/cilium/pwru \
	&& go generate \
	&& go build -v -trimpath -buildmode=pie -ldflags="-s -w" 

WORKDIR /config



# ----------------------------------------------------------------------------



#FROM scratch
FROM ubuntu:22.10@sha256:4f9ec2c0aa321966bfe625bc485aa1d6e96549679cfdf98bb404dfcb8e141a7f

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/pwru"
LABEL org.opencontainers.image.description="pwru is an eBPF-based tool for tracing network packets in the Linux kernel with advanced filtering capabilities."

COPY --from=build /go/src/github.com/cilium/pwru/pwru /usr/local/bin/pwru
COPY --from=build /config /config

ENTRYPOINT ["/usr/local/bin/pwru"]

