FROM nginx:1.31.6@sha256:78758a47dc59a81fc8354d83d17135d52cfaf6894c696886b807b9371c3648a4 AS base

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
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/ld-* /opt && \
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/libpcre* /opt && \
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/libz.so.* /opt && \
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/libzstd.so.* /opt && \
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/libc* /opt && \
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/libdl* /opt && \
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/libpthread* /opt && \
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/libcrypt* /opt && \
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/libssl.so.* /opt && \
    cp -a --parents /usr/lib/$(uname -m)-linux-gnu/libcrypto.so.* /opt && \
    cp /usr/share/zoneinfo/${TIME_ZONE:-UTC} /opt/etc/localtime

FROM gcr.io/distroless/base-debian13@sha256:0ebad3510af52aefe45045cc01b07564570be4feecf8d9f93d3a05d1b5f2f93b
#FROM gcr.io/distroless/base-debian12@sha256:fabbf1c0c357a3d42550111351daed089b20a2c954df13ee2fcff60602515e84

COPY --from=base /opt /

EXPOSE 80 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]
