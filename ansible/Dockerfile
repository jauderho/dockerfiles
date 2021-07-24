FROM ubuntu:21.10

ARG BUILD_VERSION
ARG DEBIAN_FRONTEND=noninteractive

#ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

# Labels.
LABEL maintainer="will@willhallonline.co.uk" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.name="willhallonline/ansible" \
    org.label-schema.description="Ansible inside Docker" \
    org.label-schema.url="https://github.com/willhallonline/docker-ansible" \
    org.label-schema.vcs-url="https://github.com/willhallonline/docker-ansible" \
    org.label-schema.vendor="Will Hall Online" \
    org.label-schema.docker.cmd="docker run --rm -it -v $(pwd):/ansible -v ~/.ssh/id_rsa:/root/id_rsa willhallonline/ansible:2.10-ubuntu-20.04"

RUN apt-get update && \
    DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends gnupg2 python3-pip sshpass git openssh-client && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

#RUN pip3 freeze > requirements.txt && cat requirements.txt

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
