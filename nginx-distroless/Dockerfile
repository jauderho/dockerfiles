FROM nginx:1.24.0@sha256:22cb51c7e9e05724dd1c46789e15cdb78617d1904c7c78a2829c8550c6b46e40 AS base

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
    cp -a --parents /lib/$(uname -m)-linux-gnu/libpcre.so.* /opt && \
    cp -a --parents /lib/$(uname -m)-linux-gnu/libz.so.* /opt && \
    cp -a --parents /lib/$(uname -m)-linux-gnu/libc* /opt && \
    cp -a --parents /lib/$(uname -m)-linux-gnu/libdl* /opt && \
    cp -a --parents /lib/$(uname -m)-linux-gnu/libpthread* /opt && \
    cp -a --parents /lib/$(uname -m)-linux-gnu/libcrypt* /opt && \
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/libssl.so.* /opt && \
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/libcrypto.so.* /opt && \   
    cp /usr/share/zoneinfo/${TIME_ZONE:-ROC} /opt/etc/localtime

FROM gcr.io/distroless/base-debian11@sha256:df13a91fd415eb192a75e2ef7eacf3bb5877bb05ce93064b91b83feef5431f37
#FROM gcr.io/distroless/base-debian11
#FROM gcr.io/distroless/base-debian10

COPY --from=base /opt /

EXPOSE 80 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]
