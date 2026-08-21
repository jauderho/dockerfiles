FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b
#FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

WORKDIR /ansible

ARG BUILD_VERSION
ARG DEBIAN_FRONTEND=noninteractive

#ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1
# Cap build parallelism for from-source wheels (cryptography, rpds-py, cffi, etc.)
# to avoid OOM on emulated (QEMU) architectures during concurrent multi-platform builds.
# ARG (not ENV) so they stay build-time only and don't land in the final image
ARG CARGO_BUILD_JOBS=2
ARG MAKEFLAGS=-j2

# requirements.txt now generated from Pipfile
# pipenv lock -r > requirements.txt
COPY requirements.txt .

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	build_pkgs="cargo gcc libssl-dev libkrb5-dev python3-dev git" && \
	runtime_pkgs="python3-pip openssh-client" && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends ${build_pkgs} ${runtime_pkgs} && \
	python3 -m pip install --no-cache-dir --upgrade pip --ignore-installed --break-system-packages && \
	#python3 -m pip install --no-cache-dir --upgrade --ignore-installed packaging --break-system-packages && \
	#pip3 install --no-cache-dir --upgrade wheel --break-system-packages && \
	pip3 install --no-cache-dir -r requirements.txt --ignore-installed --break-system-packages && \
	apt-get purge -y ${build_pkgs} && \
	rm -rf /usr/bin/pebble && \
	apt-get -y clean && \
	apt-get autoremove -y --purge && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /root/.cache/pip && \
	rm -rf /root/.cargo && \
	apt-get clean

#RUN pip3 install --no-cache-dir -r requirements.txt

#RUN python3 -m pip install --upgrade pip && \
#    pip3 install ansible==${BUILD_VERSION} && \
#    pip3 install ansible-lint jmespath && \
#    pip3 install pywinrm[kerberos,credssp] && \
#    rm -rf /root/.cache/pip

#RUN pip3 freeze > requirements.txt && cat requirements.txt

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/ansible"
LABEL org.opencontainers.image.description="Ansible is a radically simple IT automation platform"

RUN mkdir -p /etc/ansible && \
  echo 'localhost' > /etc/ansible/hosts

CMD [ "ansible-playbook", "--version" ]

# scratch space
#	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends cargo gcc libkrb5-dev libssl-dev python3-dev python3-pip openssh-client && \
#	pip3 install --no-cache-dir -r requirements.txt && \
#	apt-get purge -y cargo gcc libkrb5-dev libssl-dev python3-dev && \
