FROM ghcr.io/jauderho/alpine:3.22.1@sha256:6cedbe16d634f856346fb6224aeddf939413076aaf08bc0216a2ee1759917a56
#FROM alpine:edge@sha256:c8420124adc6f31031a88c85f53e1e78f419b1ac46b827fd1d4d0fdae2c7e3aa

# https://nginx.org/en/download.html
#ENV BUILD_VERSION 1.25.3

# https://www.openssl.org/source
#ENV OPENSSL_VERSION 3.2.1

# https://www.pcre.org/
#ENV PCRE_VERSION 10.42

ARG BUILD_VERSION
ARG OPENSSL_VERSION
ARG PCRE_VERSION
ARG ZLIB_URL=https://github.com/cloudflare/zlib.git
ARG BROTLI_URL=https://github.com/google/ngx_brotli.git
ARG PATCHES_URL=https://github.com/jauderho/patches.git

RUN \
  #build_pkgs="build-base linux-headers openssl-dev pcre-dev wget zlib-dev perl-dev lld ccache openssl zlib git" && \
  apk update && \
  apk upgrade -a && \
  build_pkgs="build-base linux-headers openssl-dev wget perl-dev ccache openssl zlib git mold brotli-dev" && \
  runtime_pkgs="ca-certificates tzdata brotli-libs" && \
  apk --no-cache add ${build_pkgs} ${runtime_pkgs} && \
  update-ca-certificates && \
  cd /tmp && \
  wget -O - http://freenginx.org/download/freenginx-${BUILD_VERSION}.tar.gz --tries=3 | tar zxf - -C /tmp && \
  wget -O - https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz --tries=3 | tar xzf  - -C /tmp && \
  wget -O - https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE_VERSION}/pcre2-${PCRE_VERSION}.tar.gz --tries=3 | tar xzf  - -C /tmp && \
  git clone --depth 1 ${ZLIB_URL} /tmp/zlib && \
  cd /tmp/zlib && \
  ./configure && \
  git clone --depth 1 ${BROTLI_URL} /tmp/ngx_brotli && \
  cd /tmp/ngx_brotli && \
  git submodule update --init && \
  git clone --depth 1 ${PATCHES_URL} /tmp/patches && \
  cd /tmp/freenginx-${BUILD_VERSION} && \
  NB_PROC=$(grep -c ^processor /proc/cpuinfo) && \
  echo "Patching..." && \
  patch -p1 < /tmp/patches/nginx/nginx__dynamic_tls_records_1.25.1+.patch && \
  #patch -p1 < /tmp/patches/nginx/nginx_hpack_push_1.25.0.patch && \
  patch -p1 < /tmp/patches/nginx/nginx-1.25.3-reprioritize-chacha-openssl-1.1.1.patch && \
  patch -p1 < /tmp/patches/nginx/nginx-gzip-207-status.patch && \
  ./configure \
    --prefix=/usr/share/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_v2_module \
    #--with-http_v2_hpack_enc \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --without-http_autoindex_module \
    --without-http_ssi_module \
    --with-file-aio \
    --with-threads \
    --add-module=/tmp/ngx_brotli \
    --with-cc-opt='-fuse-ld=mold -O3 -march=native -pipe -flto -ffat-lto-objects -fomit-frame-pointer -fstack-protector-strong -fstack-clash-protection -fPIE -fexceptions --param=ssp-buffer-size=4 -grecord-gcc-switches -pie -fno-semantic-interposition -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wformat-security -Wno-error=strict-aliasing -Wextra -Wp,-D_FORTIFY_SOURCE=2 -D_GLIBCXX_ASSERTIONS' \
    --with-ld-opt='-O3 -Wl,-Bsymbolic-functions -Wl,-z,relro' \
    --with-openssl=/tmp/openssl-${OPENSSL_VERSION} \
    --with-openssl-opt="enable-tfo enable-ktls no-tls-deprecated-ec enable-pie enable-ec_nistp_64_gcc_128 threads no-ssl no-tls1 no-tls1_1 no-weak-ssl-ciphers no-tests" \
    --with-pcre-jit \
    --with-pcre=/tmp/pcre2-${PCRE_VERSION} \
    --with-zlib=/tmp/zlib \
    && \
  PATH="/usr/lib/ccache:${PATH}" make -j1 && \
  ccache -s && \
  strip objs/nginx && \
  make install && \
  sed -i -e 's/#access_log  logs\/access.log  main;/access_log \/dev\/stdout;/' -e 's/#error_log  logs\/error.log  notice;/error_log stderr notice;/' /etc/nginx/nginx.conf && \
  addgroup -S nginx && \
  adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx && \
  rm -rf /tmp/* && \
  apk del ${build_pkgs} && \
  rm -rf /var/cache/apk/*

#  PATH="/usr/lib/ccache:${PATH}" make -j $NB_PROC || make -j1 && \
#    --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,--as-needed' \

LABEL org.opencontainers.image.authors "Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url "https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation "https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source "https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title "jauderho/freenginx"
LABEL org.opencontainers.image.description "freenginx is a web server"

COPY files/index.html /usr/share/nginx/html/
COPY files/nginx.conf /etc/nginx/nginx.conf

#VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

#ENTRYPOINT ["nginx"]
ENTRYPOINT ["nginx", "-g", "daemon off;"]

# Notes
#
# Use the following to enable streaming
#    --with-stream \
#    --with-stream_ssl_module \
#    --with-stream_ssl_preread_module \
#    --with-stream_realip_module \
