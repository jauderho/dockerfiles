FROM ghcr.io/jauderho/alpine:3.24.1@sha256:10b76ac1c893c93b8db0c741d0439cf2eee48cff9de40879ed735178e2fc1547 AS build

ARG BUILD_VERSION
ARG GIT_URL=https://github.com/jauderho/docker-autocompose.git

ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
	UV_NO_CACHE=1 \
	UV_LINK_MODE=copy \
	UV_PYTHON_DOWNLOADS=never

RUN \
	apk update && \
	apk upgrade -a && \
	build_pkgs="uv git python3-dev" && \
	apk --no-cache add python3 ${build_pkgs} && \
	git clone --depth 1 ${GIT_URL} /tmp/docker-autocompose && \
	# Sync from the project's own pyproject.toml and uv.lock rather than a copy
	# of its dependency list kept here. Upstream constrains the transitive deps
	# to security-patched floors, and there is nothing to drift out of step
	# with. It is a real package, so uv installs it too and the autocompose
	# console script lands in the venv. --no-editable matters: the default
	# editable install only adds a path entry pointing back at this clone,
	# which the final stage does not carry, leaving the venv unimportable.
	cd /tmp/docker-autocompose && \
	uv sync --frozen --no-dev --no-editable --python /usr/bin/python3 && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf


# ----------------------------------------------------------------------------


# Same digest as the build stage: the venv hardcodes lib/python3.X, so a
# different Python minor version here would silently break it.
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:10b76ac1c893c93b8db0c741d0439cf2eee48cff9de40879ed735178e2fc1547

COPY --from=build /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:${PATH}"

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/docker-autocompose"
LABEL org.opencontainers.image.description="docker-autocompose generates a docker-compose yaml definition from a docker container"

#WORKDIR /work

# Runtime install, smoke test and bytecode strip share one layer. A strip in a
# later layer reclaims nothing - the bytecode still sits in the apk layer - and
# running the smoke test after the strip would write __pycache__ back.
RUN \
	apk update && \
	apk upgrade -a && \
	runtime_pkgs="ca-certificates openssl python3" && \
	apk --no-cache add ${runtime_pkgs} && \
	autocompose --help > /dev/null && \
	python3 -c 'from docker_autocompose.autocompose import main; print("entrypoint importable")' && \
	rm -rf /var/cache/apk/* && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

ENTRYPOINT ["/opt/venv/bin/autocompose"]
