FROM alpine:3.14

WORKDIR /ansible

ARG BUILD_VERSION

#ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

LABEL maintainer="will@willhallonline.co.uk" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.name="willhallonline/ansible" \
    org.label-schema.description="Ansible inside Docker" \
    org.label-schema.url="https://github.com/willhallonline/docker-ansible" \
    org.label-schema.vcs-url="https://github.com/willhallonline/docker-ansible" \
    org.label-schema.vendor="Will Hall Online" \
    org.label-schema.docker.cmd="docker run --rm -it -v $(pwd):/ansible ~/.ssh/id_rsa:/root/id_rsa willhallonline/ansible:2.11-alpine-3.14"

RUN apk --no-cache add \
        sudo \
        python3\
        py3-pip \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        krb5 \
        rsync \
        git && \
    apk --no-cache add --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        musl-dev \
        gcc \
        cargo \
        openssl-dev \
        krb5-dev \
        build-base

# requirements.txt now generated from Pipfile
#COPY requirements.txt .
#RUN pip3 install --no-cache-dir pip wheel && pip3 install --no-cache-dir -r requirements.txt 

RUN pip3 install --no-cache-dir --upgrade pip wheel && \
    pip3 install --no-cache-dir ansible==${BUILD_VERSION} && \
    pip3 install --no-cache-dir ansible-lint jmespath && \
    pip3 install --no-cache-dir pywinrm[kerberos,credssp] && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache/pip && \
    rm -rf /root/.cargo

#RUN pip3 freeze > requirements.txt && cat requirements.txt

#RUN mkdir /ansible && \
RUN mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

#WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
