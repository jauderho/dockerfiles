
[![Build Status](https://github.com/jauderho/dockerfiles/workflows/ansible/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/ansible/latest)](https://hub.docker.com/r/jauderho/ansible/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/ansible)](https://hub.docker.com/r/jauderho/ansible/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/ansible/latest)](https://hub.docker.com/r/jauderho/ansible/)

This is an ansible build forked from https://github.com/willhallonline/docker-ansible/blob/master/ansible210/ubuntu2004/Dockerfile

---

Container contents:
* ansible
* ansible-lint
* mitogen (disabled for now pending support for ansible 2.10+)
* pywinrm (kerberos & credssp)

---

TODO:
* Convert to use virtualenv inside container?
* Define alternate user?
