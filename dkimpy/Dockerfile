FROM alpine:3.19.1@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b
#FROM python:3.12.1-alpine3.19@sha256:c793b92fd9e0e2a0b611756788a033d569ca864b733461c8fb30cfd14847dbcf
#FROM python:3.12.1-alpine3.19@sha256:c793b92fd9e0e2a0b611756788a033d569ca864b733461c8fb30cfd14847dbcf

ARG BUILD_VERSION

#ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

# requirements.txt now generated from Pipfile
# pipenv lock -r > requirements.txt
COPY requirements.txt . 

RUN \
	apk update && \
	apk upgrade -a && \
	build_pkgs="cargo build-base libffi-dev openssl-dev python3-dev" && \
  runtime_pkgs="ca-certificates openssl python3 py3-pip" && \
  apk --no-cache add --virtual build-dependencies ${build_pkgs} && \
  apk --no-cache add ${runtime_pkgs} && \
	python3 -m pip install --no-cache-dir --upgrade pip --break-system-packages && \
	pip3 install --no-cache-dir --upgrade wheel --break-system-packages && \
	pip3 install --no-cache-dir -r requirements.txt --break-system-packages && \
	apk del build-dependencies && \
  rm -rf /var/cache/apk/* && \
  rm -rf /root/.cache/pip && \
  find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
  find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf && \
  rm -rf /root/.cargo

#	apt-get purge -y python3-dev && \
#RUN pip install sslyze==${BUILD_VERSION}
#RUN pip3 install --no-cache-dir -r requirements.txt

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dkimpy"
LABEL org.opencontainers.image.description="dkimpy is a library that implements DKIM (DomainKeys Identified Mail) email signing and verification"

CMD ["dkimverify"]
#CMD ["dknewkey"]
#CMD ["dkimsign"]
