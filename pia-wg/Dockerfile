FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b
#FROM python:3.14.2-slim-trixie@sha256:9b81fe9acff79e61affb44aaf3b6ff234392e8ca477cb86c9f7fd11732ce9b6a

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jauderho/pia-wg/archive/
ARG GIT_URL=https://github.com/jauderho/pia-wg.git
ARG DEBIAN_FRONTEND=noninteractive

#ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

COPY entrypoint.sh .

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	# python3 is listed explicitly so purging python3-pip below cannot take it
	# with it - apt would otherwise autoremove it as an orphaned dependency,
	# and entrypoint.sh runs pia-wg/generate-config.py.
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends python3 python3-pip git qrencode wireguard-tools && \
	python3 -m pip install --no-cache-dir --upgrade pip --ignore-installed --break-system-packages && \
	git clone --depth 1 ${GIT_URL} && \
	cd pia-wg && \
	cp ca.rsa.4096.crt .. && \
	pip3 install --no-cache-dir -r requirements.txt --break-system-packages && \
	# pip is build-only here. Two copies ship otherwise (~26MB): the
	# python3-pip package, and the newer one the upgrade above puts in
	# /usr/local.
	rm -rf /usr/local/lib/python3*/dist-packages/pip \
		/usr/local/lib/python3*/dist-packages/pip-*.dist-info \
		/usr/local/bin/pip /usr/local/bin/pip3* && \
	apt-get purge -y python3-pip git && \
	rm -rf /usr/bin/pebble && \
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
