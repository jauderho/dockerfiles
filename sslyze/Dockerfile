FROM ubuntu:25.10@sha256:4a9232cc47bf99defcc8860ef6222c99773330367fcecbf21ba2edb0b810a31e

ARG BUILD_VERSION
ARG DEBIAN_FRONTEND=noninteractive

#ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

# requirements.txt now generated from Pipfile
# pipenv lock -r > requirements.txt
COPY requirements.txt . 

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends python3-pip git && \
	python3 -m pip install --no-cache-dir --upgrade pip --ignore-installed --break-system-packages && \
	#pip3 install --no-cache-dir --upgrade wheel --break-system-packages && \
	pip3 install --no-cache-dir -r requirements.txt --break-system-packages && \
	apt-get purge -y git && \
	apt-get autoremove -y --purge && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean

#	apt-get purge -y python3-dev && \
#RUN pip install sslyze==${BUILD_VERSION}
#RUN pip3 install --no-cache-dir -r requirements.txt

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/sslyze"
LABEL org.opencontainers.image.description="SSLyze is a fast and powerful SSL/TLS scanning library"

ENTRYPOINT ["sslyze"]
CMD ["-h"]
