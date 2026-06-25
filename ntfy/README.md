
[![Build Status](https://github.com/jauderho/dockerfiles/workflows/ntfy/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Antfy)
[![Version](https://img.shields.io/docker/v/jauderho/ntfy/latest)](https://github.com/binwiederhier/ntfy)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/ntfy)](https://hub.docker.com/r/jauderho/ntfy/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/ntfy/latest)](https://hub.docker.com/r/jauderho/ntfy/)

Up to date multi-platform images are built an hour after upstream release and rebuilt at least once a week.

## iOS Push Notifications

iOS push notifications require relaying through ntfy.sh's APNs gateway. Without this, messages will not be delivered to iOS devices when the app is backgrounded.

Add the following to your `server.yml`:

```yaml
upstream-base-url: "https://ntfy.sh"
```

See the [ntfy documentation](https://docs.ntfy.sh/config/#ios-instant-notifications) for details.

