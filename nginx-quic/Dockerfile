#FROM nginx AS build
FROM ghcr.io/jauderho/golang:1.24.5-alpine3.22@sha256:b161a1a5aeabb6b5ef08854550dbe9843f3da755440576068a0fab3e0287512a AS build

WORKDIR /src
COPY . .

RUN apk update && \
    apk add --no-cache git gcc make g++ cmake perl libunwind-dev ca-certificates linux-headers build-base && \
    git clone --depth 1 https://boringssl.googlesource.com/boringssl && \
    mkdir boringssl/build && \
    cd boringssl/build && \
    cmake .. && \
    make

RUN apk add --no-cache mercurial perl-dev pcre2-dev zlib-dev libxslt-dev gd-dev geoip-dev lld pcre2 zlib && \
    hg clone https://hg.nginx.org/nginx-quic && \
    cd nginx-quic && \
    hg update quic && \
    auto/configure `nginx -V 2>&1 | sed "s/ \-\-/ \\\ \n\t--/g" | grep "\-\-" | grep -ve opt= -e param= -e build=` \
      --prefix=/etc/nginx \
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
      --build=nginx-quic \
      --with-http_v3_module \
      --with-http_ssl_module \
      --with-http_realip_module \
      --with-http_v2_module \
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
      --with-cc-opt='-I/src/boringssl/include -fuse-ld=lld -O3 -march=native -pipe -flto -ffat-lto-objects -fomit-frame-pointer -fstack-protector-all -fPIE -fexceptions --param=ssp-buffer-size=4 -grecord-gcc-switches -pie -fno-semantic-interposition -Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wformat-security -Wno-error=strict-aliasing -Wextra -Wp,-D_FORTIFY_SOURCE=2' \
      --with-ld-opt='-L/src/boringssl/build/ssl -L/src/boringssl/build/crypto -O3 -Wl,-Bsymbolic-functions -Wl,-z,relro' && \
    make && \
    strip objs/nginx && \
    make install



# ----------------------------------------------------------------------------



#FROM nginx
FROM ghcr.io/jauderho/alpine:3.22.1@sha256:6cedbe16d634f856346fb6224aeddf939413076aaf08bc0216a2ee1759917a56

LABEL org.opencontainers.image.authors "Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url "https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation "https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source "https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title "jauderho/nginx-quic"
LABEL org.opencontainers.image.description "nginx is a web server"

COPY --from=build /src/nginx-quic/objs/nginx /usr/sbin
COPY --from=build /src/files/index.html /etc/nginx/html/
COPY --from=build /src/files/nginx.conf /etc/nginx/nginx.conf

COPY --from=build /etc/ssl/certs /etc/ssl/certs

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]

