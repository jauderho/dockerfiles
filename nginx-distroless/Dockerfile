FROM nginx:1.29.0@sha256:84ec966e61a8c7846f509da7eb081c55c1d56817448728924a87ab32f12a72fb AS base

# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
ARG TIME_ZONE

RUN mkdir -p /opt/var/cache/nginx && \
    cp -a --parents /usr/lib/nginx /opt && \
    cp -a --parents /usr/share/nginx /opt && \
    cp -a --parents /var/log/nginx /opt && \
    cp -aL --parents /var/run /opt && \
    cp -a --parents /etc/nginx /opt && \
    cp -a --parents /etc/passwd /opt && \
    cp -a --parents /etc/group /opt && \
    cp -a --parents /usr/sbin/nginx /opt && \
    cp -a --parents /usr/sbin/nginx-debug /opt && \
    cp -a --parents /lib/$(uname -m)-linux-gnu/ld-* /opt && \
    cp -a --parents /lib/$(uname -m)-linux-gnu/libpcre* /opt && \
    cp -a --parents /lib/$(uname -m)-linux-gnu/libz.so.* /opt && \
    cp -a --parents /lib/$(uname -m)-linux-gnu/libc* /opt && \
    cp -a --parents /lib/$(uname -m)-linux-gnu/libdl* /opt && \
    cp -a --parents /lib/$(uname -m)-linux-gnu/libpthread* /opt && \
    cp -a --parents /lib/$(uname -m)-linux-gnu/libcrypt* /opt && \
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/libssl.so.* /opt && \
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/libcrypto.so.* /opt && \   
    cp /usr/share/zoneinfo/${TIME_ZONE:-ROC} /opt/etc/localtime

FROM gcr.io/distroless/base-debian12@sha256:201ef9125ff3f55fda8e0697eff0b3ce9078366503ef066653635a3ac3ed9c26
#FROM gcr.io/distroless/base-debian11
#FROM gcr.io/distroless/base-debian10

COPY --from=base /opt /

EXPOSE 80 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]
