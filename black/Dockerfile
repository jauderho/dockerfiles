FROM alpine:3.18.0@sha256:02bb6f428431fbc2809c5d1b41eab5a68350194fb508869a33cb1af4444c9b11 AS build

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/psf/black/archive/

#ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

# requirements.txt now generated from Pipfile
# pipenv lock -r > requirements.txt
#COPY requirements.txt . 

RUN test -n "${BUILD_VERSION}" && \
	apk update && \
	apk upgrade -a && \
	build_pkgs="build-base python3-dev py3-pip" && \
	runtime_pkgs="python3" && \
	apk --no-cache add --virtual build-dependencies ${build_pkgs} && \
	apk --no-cache add ${runtime_pkgs} && \
	python3 -m pip install --no-cache-dir --upgrade pip && \
	python3 -m pip install --no-cache-dir --upgrade --ignore-installed packaging && \
	pip3 install --no-cache-dir --upgrade black==${BUILD_VERSION} && \
	#apk del build-dependencies && \
	rm -rf /var/cache/apk/* && \
	rm -rf /root/.cache/pip && \
	find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf


# ----------------------------------------------------------------------------


FROM alpine:3.18.0@sha256:02bb6f428431fbc2809c5d1b41eab5a68350194fb508869a33cb1af4444c9b11

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/black"
LABEL org.opencontainers.image.description="Black is the uncompromising Python code formatter"

RUN \
	apk update && \
	apk upgrade -a && \
	runtime_pkgs="python3" && \
	apk --no-cache add ${runtime_pkgs} && \
	rm -rf /var/cache/apk/* && \
	rm -rf /root/.cache/pip && \
	find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

COPY --from=build /usr/lib/python3.10/site-packages/ /usr/lib/python3.10/site-packages/
COPY --from=build /usr/bin/black /usr/bin/black

WORKDIR /data

ENTRYPOINT ["black"]
