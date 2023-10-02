# XoruX LPAR2RRD
This is dockerized version of single [XoruX](https://www.xorux.com) application - [LPAR2RRD](https://www.lpar2rrd.com).

It's based on the latest official [Alpine Linux](https://hub.docker.com/_/alpine) with all necessary dependencies installed.

Quick start:

    docker run -d --name LPAR2RRD --restart always -v lpar2rrd:/home/lpar2rrd ghcr.io/jauderho/lpar2rrd

You can set container timezone via env variable TIMEZONE in docker run command:

    docker run -d --name LPAR2RRD --restart always -v lpar2rrd:/home/lpar2rrd -e TIMEZONE="Etc/UTC" ghcr.io/jauderho/lpar2rrd

If you want to use this container as a XorMon backend, set XORMON env variable:

    docker run -d --name LPAR2RRD --restart always -v lpar2rrd:/home/lpar2rrd -e XORMON=1 ghcr.io/jauderho/lpar2rrd

Application UI can be found on http://\<CONTAINER_IP\>, use admin/admin for login.

---

Official images use an out of date base image with vulnerabilities hence the need for this image.

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/lpar2rrd/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/lpar2rrd/latest)](https://github.com/xorux/lpar2rrd)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/lpar2rrd)](https://hub.docker.com/r/jauderho/lpar2rrd/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/lpar2rrd/latest)](https://hub.docker.com/r/jauderho/lpar2rrd/)

Up to date multi-platform images are built an hour after upstream release and rebuilt at least once a week.
