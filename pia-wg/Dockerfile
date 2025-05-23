FROM ubuntu:25.10@sha256:36bbb8adc0662496d3e314bc8a25cb41c0c2e42ed25daaa07f8369d36d16f082
#FROM python:3.13.0-slim-bookworm@sha256:2ec5a4a5c3e919570f57675471f081d6299668d909feabd8d4803c6c61af666c
#FROM python:3.13.0-alpine3.20@sha256:81362dd1ee15848b118895328e56041149e1521310f238ed5b2cdefe674e6dbf

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jauderho/pia-wg/archive/
ARG GIT_URL=https://github.com/jauderho/pia-wg.git
ARG DEBIAN_FRONTEND=noninteractive

#ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

COPY entrypoint.sh .

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends python3-pip git qrencode wireguard-tools && \
	python3 -m pip install --no-cache-dir --upgrade pip --ignore-installed --break-system-packages && \
	git clone --depth 1 ${GIT_URL} && \
	cd pia-wg && \
	cp ca.rsa.4096.crt .. && \
	pip3 install --no-cache-dir -r requirements.txt --break-system-packages && \
	apt-get purge -y git && \
	apt-get autoremove -y --purge && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/pia-wg"
LABEL org.opencontainers.image.description="A WireGuard configuration utility for Private Internet Access"

# EXPOSE
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
# USER

#ENTRYPOINT ["python3","pia-wg/generate-config.py"]
ENTRYPOINT ["/entrypoint.sh"]
