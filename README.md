# dockerfiles

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![GitHub Super-Linter](https://github.com/jauderho/dockerfiles/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/jauderho/dockerfiles/actions/workflows/linter.yml)

This repo contains various Dockerfiles for images I have created/forked.

**Table of Contents**

<!-- toc -->

- [About](#about)
- [Status](#status)
- [Contributing](#contributing)

<!-- tocstop -->

## About

Images can be found on [Docker Hub](https://hub.docker.com/u/jauderho/) and [GitHub Container Registry](https://github.com/users/jauderho/packages?repo_name=dockerfiles).

## Status

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/ansible/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Aansible)
[![Version](https://img.shields.io/docker/v/jauderho/ansible/latest)](https://github.com/ansible/ansible/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/ansible)](https://hub.docker.com/r/jauderho/ansible/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/ansible/latest)](https://hub.docker.com/r/jauderho/ansible/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/cloudflared/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Acloudflared)
[![Version](https://img.shields.io/docker/v/jauderho/cloudflared/latest)](https://github.com/cloudflare/cloudflared)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/cloudflared)](https://hub.docker.com/r/jauderho/cloudflared/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/cloudflared/latest)](https://hub.docker.com/r/jauderho/cloudflared/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/coredns/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Acoredns)
[![Version](https://img.shields.io/docker/v/jauderho/coredns/latest)](https://github.com/coredns/coredns)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/coredns)](https://hub.docker.com/r/jauderho/coredns/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/coredns/latest)](https://hub.docker.com/r/jauderho/coredns/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/dnscontrol/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Adnscontrol)
[![Version](https://img.shields.io/docker/v/jauderho/dnscontrol/latest)](https://github.com/StackExchange/dnscontrol)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/dnscontrol)](https://hub.docker.com/r/jauderho/dnscontrol/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/dnscontrol/latest)](https://hub.docker.com/r/jauderho/dnscontrol/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/dnscrypt-proxy/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Adnscrypt-proxy)
[![Version](https://img.shields.io/docker/v/jauderho/dnscrypt-proxy/latest)](https://github.com/DNSCrypt/dnscrypt-proxy)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/dnscrypt-proxy)](https://hub.docker.com/r/jauderho/dnscrypt-proxy/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/dnscrypt-proxy/latest)](https://hub.docker.com/r/jauderho/dnscrypt-proxy/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/lego/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Alego)
[![Version](https://img.shields.io/docker/v/jauderho/lego/latest)](https://github.com/go-acme/lego)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/lego)](https://hub.docker.com/r/jauderho/lego/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/lego/latest)](https://hub.docker.com/r/jauderho/lego/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/sslyze/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Asslyze)
[![Version](https://img.shields.io/docker/v/jauderho/sslyze/latest)](https://github.com/sslyze/sslyze)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/sslyze)](https://hub.docker.com/r/jauderho/sslyze/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/sslyze/latest)](https://hub.docker.com/r/jauderho/sslyze/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/tailscale/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Atailscale)
[![Version](https://img.shields.io/docker/v/jauderho/tailscale/latest)](https://github.com/tailscale/tailscale)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/tailscale)](https://hub.docker.com/r/jauderho/tailscale/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/tailscale/latest)](https://hub.docker.com/r/jauderho/tailscale/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/terraform/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Aterraform)
[![Version](https://img.shields.io/docker/v/jauderho/terraform/latest)](https://github.com/hashicorp/terraform)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/terraform)](https://hub.docker.com/r/jauderho/terraform/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/terraform/latest)](https://hub.docker.com/r/jauderho/terraform/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/testssl.sh/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Atestssl.sh)
[![Version](https://img.shields.io/docker/v/jauderho/testssl.sh/stable)](https://github.com/drwetter/testssl.sh)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/testssl.sh)](https://hub.docker.com/r/jauderho/testssl.sh/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/testssl.sh/stable)](https://hub.docker.com/r/jauderho/testssl.sh/)

## Contributing

Pull requests are welcome.
