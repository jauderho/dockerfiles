FROM ubuntu:24.10@sha256:c62f1babc85f8756f395e6aabda682acd7c58a1b0c3bea250713cd0184a93efa
#FROM ubuntu:24.10@sha256:67541378af7d535606e684a8234d56ca0725b6a4d8b0bbf19cebefed98e06f42

WORKDIR /ansible

ARG BUILD_VERSION
ARG DEBIAN_FRONTEND=noninteractive

#ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

# requirements.txt now generated from Pipfile
# pipenv lock -r > requirements.txt
COPY requirements.txt .

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	build_pkgs="cargo gcc libssl-dev python3-dev git" && \
	runtime_pkgs="python3-pip openssh-client" && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends ${build_pkgs} ${runtime_pkgs} && \
	python3 -m pip install --no-cache-dir --upgrade pip --ignore-installed --break-system-packages && \
	#python3 -m pip install --no-cache-dir --upgrade --ignore-installed packaging --break-system-packages && \
	#pip3 install --no-cache-dir --upgrade wheel --break-system-packages && \
	pip3 install --no-cache-dir -r requirements.txt --break-system-packages && \
	apt-get purge -y ${build_pkgs} && \
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
