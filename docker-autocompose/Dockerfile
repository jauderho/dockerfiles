FROM ghcr.io/jauderho/alpine:3.24.1@sha256:10b76ac1c893c93b8db0c741d0439cf2eee48cff9de40879ed735178e2fc1547 AS build

ARG BUILD_VERSION

ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
	UV_NO_CACHE=1 \
	UV_LINK_MODE=copy \
	UV_PYTHON_DOWNLOADS=never

COPY pyproject.toml uv.lock ./

RUN \
	apk update && \
	apk upgrade -a && \
	# git: the project depends on docker-autocompose straight from a git ref
	build_pkgs="uv git python3-dev" && \
	apk --no-cache add python3 ${build_pkgs} && \
	# --no-install-project: this project only declares dependencies, there is
	# no package here to build. --frozen installs uv.lock exactly as written.
	uv sync --frozen --no-install-project --no-dev --python /usr/bin/python3 && \
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
	# The autocompose console script cannot be used as a smoke test: upstream
	# ships it importing a top-level "src" package that is not in the wheel, so
	# it raises ModuleNotFoundError on the pip build too. Import the declared
	# dependencies instead so the venv itself is still proven usable.
	python3 -c 'import docker, yaml, packaging; print(docker.__name__)' && \
	rm -rf /var/cache/apk/* && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

# The console script the project installs is named "autocompose", so the venv
# path is used here. Two pre-existing defects are NOT fixed by this migration:
# the previous ENTRYPOINT named /usr/bin/autocompose.py, which this image has
# never contained (exec failed with status 127), and the console script itself
# raises ModuleNotFoundError because upstream omits its "src" package from the
# wheel. The image was already non-functional on the pip build.
ENTRYPOINT ["/opt/venv/bin/autocompose"]
