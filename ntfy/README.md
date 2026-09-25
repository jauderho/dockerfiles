
[![Build Status](https://github.com/jauderho/dockerfiles/workflows/ntfy/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Antfy)
[![Version](https://img.shields.io/docker/v/jauderho/ntfy/latest)](https://github.com/binwiederhier/ntfy)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/ntfy)](https://hub.docker.com/r/jauderho/ntfy/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/ntfy/latest)](https://hub.docker.com/r/jauderho/ntfy/)

Up to date multi-platform images are built an hour after upstream release and rebuilt at least once a week.

## iOS Push Notifications

A self-hosted server cannot talk to APNs directly, so it must forward `poll_request` messages
through an APNs-connected upstream server (normally ntfy.sh). Only the message ID is forwarded;
the message body stays on your server.

Both settings below are required. ntfy refuses to start if `upstream-base-url` is set without
`base-url`, and `base-url` must match the URL your clients subscribe to, because the upstream
topic is derived from the topic URL.

```yaml
# /etc/ntfy/server.yml
base-url: "https://ntfy.example.com"    # your public URL, no trailing slash, no path
upstream-base-url: "https://ntfy.sh"    # must differ from base-url
#upstream-access-token: "tk_..."        # only if you exceed ntfy.sh rate limits
```

The config file is read from `/etc/ntfy/server.yml` by default:

```
docker run -p 80:80 -v /path/to/server.yml:/etc/ntfy/server.yml:ro jauderho/ntfy serve
```

The same settings can be passed as environment variables instead:

```
docker run -p 80:80 \
	-e NTFY_BASE_URL=https://ntfy.example.com \
	-e NTFY_UPSTREAM_BASE_URL=https://ntfy.sh \
	jauderho/ntfy serve
```

Without `upstream-base-url`, iOS messages still arrive, but delivery is delayed. See the
[ntfy documentation](https://docs.ntfy.sh/config/#ios-instant-notifications) for details.

