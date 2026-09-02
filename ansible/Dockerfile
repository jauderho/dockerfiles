# uv publishes linux/amd64 and linux/arm64 only. This image ships exactly those
# two platforms; anything wider needs the release tarball per TARGETARCH.
FROM ghcr.io/astral-sh/uv:0.12.9@sha256:8b940d3a9d65bed080436972241af2e21c84b5e8c9193f7014ed71479ee795ff AS uv

FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b AS build

WORKDIR /ansible

ARG BUILD_VERSION
ARG DEBIAN_FRONTEND=noninteractive
# Cap build parallelism for from-source wheels (cryptography, rpds-py, cffi, etc.)
# to avoid OOM on emulated (QEMU) architectures during concurrent multi-platform builds.
# ARG (not ENV) so they stay build-time only and don't land in the final image
ARG CARGO_BUILD_JOBS=2
ARG MAKEFLAGS=-j2

ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
	UV_NO_CACHE=1 \
	UV_LINK_MODE=copy \
	UV_PYTHON_DOWNLOADS=never

COPY --from=uv /uv /usr/local/bin/uv
COPY pyproject.toml uv.lock ./

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	# ca-certificates: git verifies TLS with the system trust store, and
	# --no-install-recommends leaves it out otherwise.
	build_pkgs="cargo gcc libssl-dev libkrb5-dev python3-dev ca-certificates git" && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends python3 ${build_pkgs} && \
	# --no-install-project: this project only declares dependencies, there is
	# no package here to build. --frozen installs uv.lock exactly as written.
	uv sync --frozen --no-install-project --no-dev --python /usr/bin/python3 && \
	collections=$(/opt/venv/bin/python3 -c 'import ansible_collections;print(ansible_collections.__path__[0])') && \
	# The ansible metapackage ships ~93 collections whole. Three parts of that
	# tree are never read when running playbooks or linting (~165MB combined):
	#   tests/       - only consumed by ansible-test
	#   changelogs/  - release notes and their fragments
	#   __pycache__/ - the bulk of it, ~158MB. Modules are shipped to the target
	#                  by AnsiballZ rather than imported locally, so almost none
	#                  of this bytecode is ever loaded; what is gets recompiled
	#                  at no measurable cost (measured: <1% on playbook runtime)
	# Depth is pinned to <namespace>/<collection>/ so the plugins/test/ trees
	# that hold Jinja test plugins are left alone.
	find "${collections}" -mindepth 3 -maxdepth 3 -type d \( -name tests -o -name changelogs \) -prune -exec rm -rf {} + && \
	find "${collections}" -depth -type d -name __pycache__ -exec rm -rf {} + && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf


# ----------------------------------------------------------------------------


# Same digest as the build stage: the venv hardcodes lib/python3.X, so a
# different Python minor version here would silently break it.
FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

WORKDIR /ansible

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=build /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:${PATH}"

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/ansible"
LABEL org.opencontainers.image.description="Ansible is a radically simple IT automation platform"

# Runtime install, smoke test and bytecode strip share one layer: running the
# smoke test after a separate strip would write __pycache__ straight back.
# libkrb5-3 and libgssapi-krb5-2 are the runtime halves of libkrb5-dev, needed
# by the pyspnego/requests-kerberos extensions built above.
RUN apt-get update && \
	apt-get dist-upgrade -y && \
	runtime_pkgs="python3 ca-certificates openssh-client libkrb5-3 libgssapi-krb5-2" && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends ${runtime_pkgs} && \
	mkdir -p /etc/ansible && \
	echo 'localhost' > /etc/ansible/hosts && \
	ansible-playbook --version && \
	ansible-lint --version && \
	python3 -c 'import ansible, jmespath, winrm, mitogen; print(ansible.__version__)' && \
	rm -rf /usr/bin/pebble && \
	apt-get autoremove -y --purge && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf

CMD [ "ansible-playbook", "--version" ]
