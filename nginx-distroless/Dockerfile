FROM nginx:1.29.3@sha256:ceac0cf9899a7635bca94200e634aaa5183386f544dc16522f5b98f27d77039a AS base

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
    cp /usr/share/zoneinfo/${TIME_ZONE:-UTC} /opt/etc/localtime

#FROM gcr.io/distroless/base-debian13@sha256:894e78799ebace28d56fc226a05d76a601685e1382421299eed8b7a95b90fa9e
FROM gcr.io/distroless/base-debian12@sha256:9e9b50d2048db3741f86a48d939b4e4cc775f5889b3496439343301ff54cdba8

COPY --from=base /opt /

EXPOSE 80 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]
