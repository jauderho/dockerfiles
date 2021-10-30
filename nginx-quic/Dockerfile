#FROM nginx AS build
FROM ubuntu:21.10 AS build

WORKDIR /src
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git gcc make g++ cmake perl libunwind-dev golang ca-certificates && \
    git clone --depth 1 https://boringssl.googlesource.com/boringssl && \
    mkdir boringssl/build && \
    cd boringssl/build && \
    cmake .. && \
    make

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mercurial libperl-dev libpcre3-dev zlib1g-dev libxslt1-dev libgd-ocaml-dev libgeoip-dev && \
    hg clone https://hg.nginx.org/nginx-quic && \
    cd nginx-quic && \
    hg update quic && \
    auto/configure `nginx -V 2>&1 | sed "s/ \-\-/ \\\ \n\t--/g" | grep "\-\-" | grep -ve opt= -e param= -e build=` \
                   --build=nginx-quic \
                   --with-http_v3_module --with-http_quic_module --with-stream_quic_module \
                   --with-cc-opt="-I/src/boringssl/include" --with-ld-opt="-L/src/boringssl/build/ssl -L/src/boringssl/build/crypto" && \
    make

#FROM nginx
FROM ubuntu:21.10
COPY --from=build /src/nginx-quic/objs/nginx /usr/sbin
RUN /usr/sbin/nginx -V > /dev/stderr
EXPOSE 80 443
