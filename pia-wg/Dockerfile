# uv publishes linux/amd64 and linux/arm64 only. This image ships exactly those
# two platforms; anything wider needs the release tarball per TARGETARCH.
FROM ghcr.io/astral-sh/uv:0.12.8@sha256:d1cbaeadc234fe19c0d93daabcf5e98738cd93c6d1dd4918ef6aa30735feb23a AS uv

FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b AS build
#FROM python:3.14.2-slim-trixie@sha256:9b81fe9acff79e61affb44aaf3b6ff234392e8ca477cb86c9f7fd11732ce9b6a

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/jauderho/pia-wg/archive/
ARG GIT_URL=https://github.com/jauderho/pia-wg.git
ARG DEBIAN_FRONTEND=noninteractive

ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
	UV_NO_CACHE=1 \
	UV_LINK_MODE=copy \
	UV_PYTHON_DOWNLOADS=never

COPY --from=uv /uv /usr/local/bin/uv

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	# ca-certificates: git verifies TLS with the system trust store, and
	# --no-install-recommends leaves it out otherwise.
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends \
		python3 ca-certificates git && \
	git clone --depth 1 ${GIT_URL} /pia-wg && \
	# Sync from the utility's own pyproject.toml and uv.lock rather than a copy
	# of its dependency list kept here. Upstream constrains the transitive deps
	# to security-patched floors, and there is nothing to drift out of step
	# with. It sets package = false, so uv installs the dependencies only;
	# --no-dev leaves its ruff dev-group behind.
	cd /pia-wg && \
	uv sync --frozen --no-dev --python /usr/bin/python3 && \
	cp /pia-wg/ca.rsa.4096.crt / && \
	rm -rf /pia-wg/.git && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf


# ----------------------------------------------------------------------------


# Same digest as the build stage: the venv hardcodes lib/python3.X, so a
# different Python minor version here would silently break it.
FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

ARG DEBIAN_FRONTEND=noninteractive

COPY entrypoint.sh .
COPY --from=build /opt/venv /opt/venv
COPY --from=build /pia-wg /pia-wg
COPY --from=build /ca.rsa.4096.crt /ca.rsa.4096.crt

# entrypoint.sh calls "python3 pia-wg/generate-config.py", so the venv has to
# be ahead of /usr/bin on PATH.
ENV PATH="/opt/venv/bin:${PATH}"

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/pia-wg"
LABEL org.opencontainers.image.description="A WireGuard configuration utility for Private Internet Access"

# Runtime install, smoke test and bytecode strip share one layer: running the
# smoke test after a separate strip would write __pycache__ straight back.
RUN apt-get update && \
	apt-get dist-upgrade -y && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends \
		python3 ca-certificates qrencode wireguard-tools && \
	python3 -c 'import requests, requests_toolbelt, pick; print(requests.__version__)' && \
	python3 -c 'import sys; sys.path.insert(0, "/pia-wg"); import piawg; print("piawg OK")' && \
	rm -rf /usr/bin/pebble && \
	apt-get autoremove -y --purge && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf

# EXPOSE
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
# USER

#ENTRYPOINT ["python3","pia-wg/generate-config.py"]
ENTRYPOINT ["/entrypoint.sh"]
