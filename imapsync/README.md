
Usage: `docker run --rm -it jauderho/imapsync:latest `

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/imapsync/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/imapsync/latest)](https://github.com/imapsync/imapsync/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/age)](https://hub.docker.com/r/jauderho/imapsync/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/imapsync/latest)](https://hub.docker.com/r/jauderho/imapsync/)

Up to date multi-platform images are rebuilt at least once a week.

This image differs from the official image in the following ways:
- Ubuntu 22.04 is used as the base image due to the need to use a version of IO::Socket::SSL >= 2.073
- Remove testing and modules needed for testing
- Only add needed packages (--no-install-recommends)
- Use ENTRYPOINT instead of CMD

# First run
This can be rerun repeatedly until all messages are fully copied over to the destination.

```
docker run --rm -it jauderho/imapsync:latest \
	--errorsmax 200 \
	--gmail1 \
	--user1 jauderho@carumba.com \
	--compress1 \
	--ssl1 --sslargs1 SSL_verify_mode=1 \
	--host2 imap.mail.me.com \
	--user2 jauderho@icloud.com \
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

# Final run
WARNING: This will delete all emails from the source system as part of the final run.

```
docker run --rm -it jauderho/imapsync:latest \
  --errorsmax 200 \
  --gmail1 \
	--user1 jauderho@carumba.com \
  --compress1 \
  --ssl1 --sslargs1 SSL_verify_mode=1 \
  --host2 imap.mail.me.com \
	--user2 jauderho@icloud.com \
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
  --f1f2 '[Gmail]/All Mail=Archive' \
	--delete1 --delete1emptyfolders --expunge1
```
