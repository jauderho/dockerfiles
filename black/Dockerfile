FROM ghcr.io/jauderho/alpine:3.24.1@sha256:10b76ac1c893c93b8db0c741d0439cf2eee48cff9de40879ed735178e2fc1547 AS build

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/psf/black/archive/

ENV UV_NO_CACHE=1 \
	UV_LINK_MODE=copy \
	UV_PYTHON_DOWNLOADS=never

# There is no pyproject.toml or uv.lock here: BUILD_VERSION is the single
# source of truth for which black ships, so uv installs that exact version
# straight into the venv. build-base and python3-dev are kept because black
# publishes mypyc-compiled wheels for the common arches only, so ppc64le and
# s390x build it from source.
RUN test -n "${BUILD_VERSION}" && \
	apk update && \
	apk upgrade -a && \
	build_pkgs="uv build-base python3-dev" && \
	apk --no-cache add python3 ${build_pkgs} && \
	uv venv /opt/venv --python /usr/bin/python3 && \
	uv pip install --python /opt/venv/bin/python "black==${BUILD_VERSION}" && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf


# ----------------------------------------------------------------------------


# Same digest as the build stage: the venv hardcodes lib/python3.X, so a
# different Python minor version here would silently break it.
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:10b76ac1c893c93b8db0c741d0439cf2eee48cff9de40879ed735178e2fc1547

ARG BUILD_VERSION

COPY --from=build /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:${PATH}"

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/black"
LABEL org.opencontainers.image.description="Black is the uncompromising Python code formatter"

WORKDIR /data

# Runtime install, smoke test and bytecode strip share one layer. A strip in a
# later layer reclaims nothing - the bytecode still sits in the apk layer - and
# running the smoke test after the strip would write __pycache__ back.
RUN \
	apk update && \
	apk upgrade -a && \
	runtime_pkgs="ca-certificates python3" && \
	apk --no-cache add ${runtime_pkgs} && \
	black --version && \
	black --version | grep -q "${BUILD_VERSION}" && \
	printf 'x = {  "a":1 }\n' > /tmp/t.py && black -q /tmp/t.py && rm -f /tmp/t.py && \
	rm -rf /var/cache/apk/* && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

ENTRYPOINT ["black"]
