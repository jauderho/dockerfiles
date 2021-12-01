
[![Build Status](https://github.com/jauderho/dockerfiles/workflows/ansible/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/ansible/latest)](https://hub.docker.com/r/jauderho/ansible/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/ansible)](https://hub.docker.com/r/jauderho/ansible/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/ansible/latest)](https://hub.docker.com/r/jauderho/ansible/)

This is an ansible build forked from:
* *https://github.com/willhallonline/docker-ansible/blob/master/ansible210/ubuntu2004/Dockerfile
* https://github.com/willhallonline/docker-ansible/blob/master/ansible211/alpine314/Dockerfile

---

Container contents of Ubuntu image:
* ansible
* ansible-lint
* pywinrm
* storops
* <s>mitogen</s>

---

Container contents of Alpine image:
* ansible
* ansible-lint
* pywinrm

---

TODO:
* Convert to use virtualenv/pipenv inside container?
* Define alternate user?
