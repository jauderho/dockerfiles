#FROM ubuntu:23.04@sha256:9279f41cc6e4df8f87b13ac17c2c6f2a280fd3ca2638d18f8dc94b774486909f
FROM ubuntu:23.04@sha256:9279f41cc6e4df8f87b13ac17c2c6f2a280fd3ca2638d18f8dc94b774486909f
#FROM python:3.9-slim
#FROM python:3.11.4-alpine3.18@sha256:995c7fcdf9a10e0e1a4555861dac63436b456822a167f07b6599d4f105de6fa0

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
	python3 -m pip install --no-cache-dir --upgrade pip --break-system-packages && \
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
