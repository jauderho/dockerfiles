FROM ghcr.io/jauderho/alpine:3.20.1@sha256:cf7d1c3fd3bb25c1153f9fb9a5849f33c57b4aa8ce7d57a24f7ca91b7877538f
#FROM python:3.13.0b1-alpine3.19@sha256:f2028c7ea4005bfa797d91717dc8f5f8990bb592d10d5b014513ac4405f99267

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

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/dkimpy"
LABEL org.opencontainers.image.description="dkimpy is a library that implements DKIM (DomainKeys Identified Mail) email signing and verification"

CMD ["dkimverify"]
#CMD ["dknewkey"]
#CMD ["dkimsign"]
