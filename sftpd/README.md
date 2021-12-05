
[![Build Status](https://github.com/jauderho/dockerfiles/workflows/sftpd/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Asftpd)
[![Version](https://img.shields.io/docker/v/jauderho/sftpd/latest)](https://github.com/openssh/openssh-portable)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/sftpd)](https://hub.docker.com/r/jauderho/sftpd/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/sftpd/latest)](https://hub.docker.com/r/jauderho/sftpd/)

Dockerfile forked from https://github.com/atmoz/sftp

Changes from atmoz/sftp:
- Modern SSH crypto (see files/sshd_config)
- Alter default listening port to 2222
- Only allow auth via SSH keys

