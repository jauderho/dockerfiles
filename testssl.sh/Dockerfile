FROM alpine:3.13

WORKDIR /home/testssl

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/drwetter/testssl.sh/archive/

RUN test -n "${BUILD_VERSION}" \
    && apk update \
    && apk add --no-cache bash procps drill git coreutils libidn curl socat openssl xxd \
    && curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/testssl.tar.gz \
	&& tar xzf /tmp/testssl.tar.gz --strip 1 -C /home/testssl \
    && addgroup testssl \
    && adduser -G testssl -g "testssl user" -s /bin/bash -D testssl \
    && ln -s /home/testssl/testssl.sh /usr/local/bin/ \
    && mkdir -m 755 -p /home/testssl/etc /home/testssl/bin

RUN ls -lrt

#COPY /etc/ssl/certs /etc/ssl/certs
#COPY --chown=testssl:testssl etc/. /home/testssl/etc/
#COPY --chown=testssl:testssl bin/. /home/testssl/bin/
#COPY --chown=testssl:testssl testssl.sh /home/testssl/

USER testssl

ENTRYPOINT ["testssl.sh"]

CMD ["--help"]
