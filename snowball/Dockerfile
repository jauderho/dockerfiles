FROM ubuntu:25.10@sha256:9b61739164b58f2263067bd3ab31c7746ded4cade1f9d708e6f1b047b408a470

ARG BUILD_VERSION
ARG TARBALL_URL=https://snowball-client.s3.us-west-2.amazonaws.com/latest/snowball-client-linux.tar.gz

RUN test -n "${BUILD_VERSION}" \
	&& apt-get update \
	&& apt-get dist-upgrade -y \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates curl \
	&& curl -L "${TARBALL_URL}" -o /tmp/snowball.tar.gz \
	&& tar xzf /tmp/snowball.tar.gz --strip 1 -C /usr/local \
	&& rm -rf /tmp/snowball.tar.gz \
	&& apt-get purge -y curl \
	&& apt-get autoremove -y --purge \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/snowball"
LABEL org.opencontainers.image.description="The Snowball Edge Client is used to manage a Snowball device"

# EXPOSE
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
# USER

CMD ["/usr/local/bin/snowball"]

