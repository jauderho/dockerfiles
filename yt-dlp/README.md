
[![Build Status](https://github.com/jauderho/dockerfiles/workflows/yt-dlp/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/yt-dlp/latest)](https://github.com/yt-dlp/yt-dlp)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/yt-dlp)](https://hub.docker.com/r/jauderho/yt-dlp/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/yt-dlp/latest)](https://hub.docker.com/r/jauderho/yt-dlp/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/yt-dlp-nightly-builds/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/yt-dlp-nightly-builds/nightly)](https://github.com/yt-dlp/yt-dlp-nightly-builds)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/yt-dlp-nightly-builds)](https://hub.docker.com/r/jauderho/yt-dlp-nightly-builds/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/yt-dlp-nightly-builds/nightly)](https://hub.docker.com/r/jauderho/yt-dlp-nightly-builds/)

Usage:

* `docker run --rm -it ghcr.io/jauderho/yt-dlp:latest`
* `docker run --rm -it -v "$(pwd):/downloads:rw" ghcr.io/jauderho/yt-dlp:latest` (download to the current directory)

Up to date multi-platform images are built an hour after upstream release and rebuilt at least once a week.
