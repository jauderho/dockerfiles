FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

ARG BUILD_VERSION
ARG DEBIAN_FRONTEND=noninteractive

#ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

# requirements.txt now generated from Pipfile
# pipenv lock -r > requirements.txt
COPY requirements.txt . 

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	# python3 is listed explicitly so purging python3-pip below cannot take it
	# with it - apt would otherwise autoremove it as an orphaned dependency.
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends python3 python3-pip git && \
	python3 -m pip install --no-cache-dir --upgrade pip --ignore-installed --break-system-packages && \
	#pip3 install --no-cache-dir --upgrade wheel --break-system-packages && \
	# requirements.txt is a complete pinned closure (uv export). Install with
	# --no-deps to override sslyze's upper bound on cryptography (sslyze pins
	# cryptography<47) and pull the newer, tested-working version. See the
	# override-dependencies entry in pyproject.toml.
	pip3 install --no-cache-dir --no-deps -r requirements.txt --break-system-packages && \
	# pip is build-only here; the entrypoint is the sslyze console script. Two
	# copies ship otherwise (~26MB): the python3-pip package, and the newer one
	# the upgrade above installs into /usr/local.
	rm -rf /usr/local/lib/python3*/dist-packages/pip \
		/usr/local/lib/python3*/dist-packages/pip-*.dist-info \
		/usr/local/bin/pip /usr/local/bin/pip3* && \
	apt-get purge -y python3-pip git && \
	rm -rf /usr/bin/pebble && \
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
