FROM alpine:3.16.0@sha256:002e139741ad820846f0c5bb26442468ccafbc0ec1898346613f4d988fc72cd0

RUN apk --no-cache add dhcp-helper

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dhcp-helper"
LABEL org.opencontainers.image.description="dhcp-helper is a DHCP and BOOTP relay agent"

EXPOSE 67 67/udp
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
# USER

ENTRYPOINT ["dhcp-helper", "-n"]

