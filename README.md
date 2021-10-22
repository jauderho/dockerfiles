# dockerfiles

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![GitHub Super-Linter](https://github.com/jauderho/dockerfiles/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/jauderho/dockerfiles/actions/workflows/linter.yml)

This repo contains Dockerfiles for various applications that I find useful. Upstream repos are monitored and new images will be built an hour after a new release is tagged. Whenever possible, images will be optimized for size.

**Table of Contents**

<!-- toc -->

- [About](#about)
- [Status](#status)
- [Contributing](#contributing)

<!-- tocstop -->

## About

Images can be found on [Docker Hub](https://hub.docker.com/u/jauderho/) and [GitHub Container Registry](https://github.com/users/jauderho/packages?repo_name=dockerfiles).

## Status

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/age/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/age/latest)](https://github.com/FiloSottile/age)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/age)](https://hub.docker.com/r/jauderho/age/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/age/latest)](https://hub.docker.com/r/jauderho/age/)

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

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/dive/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/dive/latest)](https://github.com/wagoodman/dive)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/dive)](https://hub.docker.com/r/jauderho/dive/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/dive/latest)](https://hub.docker.com/r/jauderho/dive/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/dnscontrol/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Adnscontrol)
[![Version](https://img.shields.io/docker/v/jauderho/dnscontrol/latest)](https://github.com/StackExchange/dnscontrol)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/dnscontrol)](https://hub.docker.com/r/jauderho/dnscontrol/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/dnscontrol/latest)](https://hub.docker.com/r/jauderho/dnscontrol/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/dnscrypt-proxy/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Adnscrypt-proxy)
[![Version](https://img.shields.io/docker/v/jauderho/dnscrypt-proxy/latest)](https://github.com/DNSCrypt/dnscrypt-proxy)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/dnscrypt-proxy)](https://hub.docker.com/r/jauderho/dnscrypt-proxy/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/dnscrypt-proxy/latest)](https://hub.docker.com/r/jauderho/dnscrypt-proxy/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/excalidraw/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/excalidraw/latest)](https://github.com/excalidraw/excalidraw/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/age)](https://hub.docker.com/r/jauderho/excalidraw/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/excalidraw/latest)](https://hub.docker.com/r/jauderho/excalidraw/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/gobgp/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/gobgp/latest)](https://github.com/osrg/gobgp)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/gobgp)](https://hub.docker.com/r/jauderho/gobgp/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/gobgp/latest)](https://hub.docker.com/r/jauderho/gobgp/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/headscale/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/headscale/latest)](https://github.com/juanfont/headscale/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/age)](https://hub.docker.com/r/jauderho/headscale/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/headscale/latest)](https://hub.docker.com/r/jauderho/headscale/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/lego/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Alego)
[![Version](https://img.shields.io/docker/v/jauderho/lego/latest)](https://github.com/go-acme/lego)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/lego)](https://hub.docker.com/r/jauderho/lego/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/lego/latest)](https://hub.docker.com/r/jauderho/lego/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/miller/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/miller/latest)](https://github.com/johnkerl/miller)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/miller)](https://hub.docker.com/r/jauderho/miller/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/miller/latest)](https://hub.docker.com/r/jauderho/miller/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/nebula/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/nebula/latest)](https://github.com/slackhq/nebula/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/age)](https://hub.docker.com/r/jauderho/nebula/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/nebula/latest)](https://hub.docker.com/r/jauderho/nebula/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/nginx/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/nginx/latest)](https://github.com/nginx/nginx)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/nginx)](https://hub.docker.com/r/jauderho/nginx/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/nginx/latest)](https://hub.docker.com/r/jauderho/nginx/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/onetun/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/onetun/latest)](https://github.com/aramperes/onetun/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/age)](https://hub.docker.com/r/jauderho/onetun/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/onetun/latest)](https://hub.docker.com/r/jauderho/onetun/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/pwru/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/pwru/latest)](https://github.com/cilium/pwru)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/pwru)](https://hub.docker.com/r/jauderho/pwru/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/pwru/latest)](https://hub.docker.com/r/jauderho/pwru/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/spicedb/badge.svg)](https://github.com/jauderho/dockerfiles/actions)
[![Version](https://img.shields.io/docker/v/jauderho/spicedb/latest)](https://github.com/authzed/spicedb/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/age)](https://hub.docker.com/r/jauderho/spicedb/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/spicedb/latest)](https://hub.docker.com/r/jauderho/spicedb/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/ssh-audit/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Assh-audit)
[![Version](https://img.shields.io/docker/v/jauderho/ssh-audit/latest)](https://github.com/jtesta/ssh-audit)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/ssh-audit)](https://hub.docker.com/r/jauderho/ssh-audit/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/ssh-audit/latest)](https://hub.docker.com/r/jauderho/ssh-audit/)

[![Build Status](https://github.com/jauderho/dockerfiles/workflows/sslyze/badge.svg)](https://github.com/jauderho/dockerfiles/actions?query=workflow%3Asslyze)
[![Version](https://img.shields.io/docker/v/jauderho/sslyze/latest)](https://github.com/nabla-c0d3/sslyze)
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
[![Version](https://img.shields.io/docker/v/jauderho/testssl.sh/latest)](https://github.com/drwetter/testssl.sh)
[![Docker Pulls](https://img.shields.io/docker/pulls/jauderho/testssl.sh)](https://hub.docker.com/r/jauderho/testssl.sh/)
[![Image Size](https://img.shields.io/docker/image-size/jauderho/testssl.sh/latest)](https://hub.docker.com/r/jauderho/testssl.sh/)

## Contributing

Pull requests are welcome.
