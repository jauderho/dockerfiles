
Usage: `docker run --rm -it jauderho/imapsync:latest `

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/imapsync/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/imapsync/latest)](https://github.com/imapsync/imapsync/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/imapsync)](https://hub.docker.com/r/jauderho/imapsync/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/imapsync/latest)](https://hub.docker.com/r/jauderho/imapsync/)

Up to date multi-platform images are rebuilt at least once a week.

This image differs from the official image in the following ways:
- Ubuntu 22.04 is used as the base image due to the need to use a version of IO::Socket::SSL >= 2.073
- Remove testing and modules needed for testing
- Only add needed packages (--no-install-recommends)
- Use ENTRYPOINT instead of CMD
- Half the size!

The examples below show how to migrate from Gmail to Apple Mail.

## Docker Compose (recommended)

```
#
# Create a .env in the same directory with the following information before running docker compose
#
# IMAPSYNC_USER1=
# IMAPSYNC_PASSWORD1=
# IMAPSYNC_USER2=
# IMAPSYNC_PASSWORD2=
#

services:
  imapsync:
    #build: .
    container_name: imapsync
    image: ghcr.io/jauderho/imapsync:latest
    command: ["--errorsmax", "200", 
              "--gmail1", 
              "--user1", "${IMAPSYNC_USER1}", 
              "--password1", "${IMAPSYNC_PASSWORD1}",
              "--compress1", 
              "--ssl1", 
              "--sslargs1", "SSL_verify_mode=1", 
              "--host2", "imap.mail.me.com", 
              "--user2", "${IMAPSYNC_USER2}", 
              "--password2", "${IMAPSYNC_PASSWORD2}", 
              "--compress2", 
              "--ssl2", 
              "--sslargs2", "SSL_verify_mode=1", 
              "--maxbytespersecond", "200_000", 
              "--maxbytesafter", "3_000_000_000", 
              "--addheader", "--useheader", 'Message-Id', 
              "--no-modulesversion", 
              "--nochecknoabletosearch", 
              "--nofoldersizes", 
              "--nofoldersizesatend", 
              "--skipcrossduplicates", 
              "--syncinternaldates", 
              "--folderlast", '[Gmail]/All Mail',  
              "--f1f2", '[Gmail]/All Mail=Archive']
```

Store environment variables in .env:

```
IMAPSYNC_USER1=
IMAPSYNC_PASSWORD1=
IMAPSYNC_USER2=
IMAPSYNC_PASSWORD2=
```

## Docker

### First run
This can be rerun repeatedly until all messages are fully copied over to the destination.

```
docker run --rm -it ghcr.io/jauderho/imapsync:latest \
	--errorsmax 200 \
	--gmail1 \
	--user1 <user@domain.com> \
	--compress1 \
	--ssl1 --sslargs1 SSL_verify_mode=1 \
	--host2 imap.mail.me.com \
	--user2 <user@icloud.com> \
	--compress2 \
	--ssl2 --sslargs2 SSL_verify_mode=1 \
	--maxbytespersecond 200_000 \
	--maxbytesafter 3_000_000_000 \
	--addheader --useheader 'Message-Id' \
	--no-modulesversion \
	--nochecknoabletosearch \
	--nofoldersizes \
	--nofoldersizesatend \
	--skipcrossduplicates \
	--syncinternaldates \
	--folderlast '[Gmail]/All Mail' \
	--f1f2 '[Gmail]/All Mail=Archive'
```

### Final run
WARNING: This will delete all emails from the source system as part of the final run.

```
docker run --rm -it ghcr.io/jauderho/imapsync:latest \
	--errorsmax 200 \
	--gmail1 \
	--user1 <user@domain.com> \
	--compress1 \
	--ssl1 --sslargs1 SSL_verify_mode=1 \
	--host2 imap.mail.me.com \
	--user2 <user@icloud.com> \
	--compress2 \
	--ssl2 --sslargs2 SSL_verify_mode=1 \
	--maxbytespersecond 200_000 \
	--maxbytesafter 3_000_000_000 \
	--addheader --useheader 'Message-Id' \
	--no-modulesversion \
	--nochecknoabletosearch \
	--nofoldersizes \
	--nofoldersizesatend \
	--skipcrossduplicates \
	--syncinternaldates \
	--folderlast '[Gmail]/All Mail' \
	--f1f2 '[Gmail]/All Mail=Archive'
```
