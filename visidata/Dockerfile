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
	build_pkgs="uv python3-dev libxml2-dev libxslt-dev gcc build-base" && \
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

COPY .visidatarc ./

ENV PATH="/opt/venv/bin:${PATH}"

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/visidata"
LABEL org.opencontainers.image.description="Visidata is a terminal interface for exploring and arranging tabular data"

# Runtime install, smoke test and bytecode strip share one layer. A strip in a
# later layer reclaims nothing - the bytecode still sits in the apk layer - and
# running the smoke test after the strip would write __pycache__ back.
RUN \
	apk update && \
	apk upgrade -a && \
	runtime_pkgs="ca-certificates openssl python3 libxml2 libxslt" && \
	apk --no-cache add ${runtime_pkgs} && \
	vd --version && \
	rm -rf /var/cache/apk/* && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

WORKDIR /work

ENV TERM="xterm-256color"

ENTRYPOINT ["vd"]
