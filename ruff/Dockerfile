FROM ghcr.io/jauderho/alpine:3.24.1@sha256:10b76ac1c893c93b8db0c741d0439cf2eee48cff9de40879ed735178e2fc1547 AS build
#FROM python:3.14.6-alpine3.24@sha256:003970a263347645cd23d4f90929ad16ba7ce7d808ee4674ffcc93cb21cc289f

ARG BUILD_VERSION

ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
	UV_NO_CACHE=1 \
	UV_LINK_MODE=copy \
	UV_PYTHON_DOWNLOADS=never

COPY pyproject.toml uv.lock ./

RUN \
	apk update && \
	apk upgrade -a && \
	build_pkgs="uv" && \
	runtime_pkgs="python3" && \
	apk --no-cache add ${build_pkgs} ${runtime_pkgs} && \
	# --no-install-project: this project only declares dependencies, there is
	# no package here to build. --frozen installs uv.lock exactly as written.
	uv sync --frozen --no-install-project --no-dev --python /usr/bin/python3 && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf


# ----------------------------------------------------------------------------


# Same digest as the build stage: the venv hardcodes lib/python3.X, so a
# different Python minor version in this stage would silently break it.
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:10b76ac1c893c93b8db0c741d0439cf2eee48cff9de40879ed735178e2fc1547

COPY --from=build /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:${PATH}"

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/ruff"
LABEL org.opencontainers.image.description="ruff is an extremely fast Python linter and code formatter, written in Rust"

WORKDIR /data

# Runtime install, smoke test and bytecode strip share one layer. A strip in a
# later layer reclaims nothing - the bytecode still sits in the apk layer - and
# running the smoke test after the strip would write __pycache__ back.
RUN \
	apk update && \
	apk upgrade -a && \
	runtime_pkgs="ca-certificates openssl python3" && \
	apk --no-cache add ${runtime_pkgs} && \
	ruff --version && \
	rm -rf /var/cache/apk/* && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

ENTRYPOINT ["ruff"]
CMD ["-h"]
