#FROM ubuntu:23.10@sha256:4c32aacd0f7d1d3a29e82bee76f892ba9bb6a63f17f9327ca0d97c3d39b9b0ee
FROM ubuntu:23.10@sha256:4c32aacd0f7d1d3a29e82bee76f892ba9bb6a63f17f9327ca0d97c3d39b9b0ee
#FROM python:python:3.12.0-slim-bookworm@sha256:43a49c9cc2e614468e3d1a903aabe17a97a4c788c76cf5337b5cdc3535b07d4f
#FROM python:3.12.0-alpine3.18@sha256:ae35274f417fc81ba6ee1fc84206e8517f28117566ee6a04a64f004c1409bdac

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
