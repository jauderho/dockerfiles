
[![Build Status](https://github.com/jauderho/dockerfiles/workflows/ntfy/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Antfy)
[![Version](https://img.shields.io/docker/v/jauderho/ntfy/latest)](https://github.com/binwiederhier/ntfy)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/ntfy)](https://hub.docker.com/r/jauderho/ntfy/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/ntfy/latest)](https://hub.docker.com/r/jauderho/ntfy/)

Up to date multi-platform images are built an hour after upstream release and rebuilt at least once a week.

## iOS Notifications (APNS Setup)

For iOS notifications to work, you must configure APNS (Apple Push Notification Service) in your `ntfy` server configuration file (usually `server.yml`). This requires an APNS authentication key (`.p8` file), Key ID, and Team ID, which can be obtained from your Apple Developer account.

It is strongly recommended to consult the official `ntfy` documentation at `https://ntfy.sh/docs/config/#ios-notifications-apns` for detailed instructions on generating these credentials and configuring the `server.yml` file.

Conceptually, you would mount your `server.yml` file when running the Docker container like so:

```
docker run -v /path/to/your/server.yml:/etc/ntfy/server.yml jauderho/ntfy ...
```
