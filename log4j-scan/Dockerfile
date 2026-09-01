FROM ghcr.io/jauderho/alpine:3.24.1@sha256:10b76ac1c893c93b8db0c741d0439cf2eee48cff9de40879ed735178e2fc1547 AS build

ARG BUILD_VERSION
#ARG GIT_URL=https://github.com/fullhunt/log4j-scan.git
ARG GIT_URL=https://github.com/jauderho/log4j-scan.git

ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
	UV_NO_CACHE=1 \
	UV_LINK_MODE=copy \
	UV_PYTHON_DOWNLOADS=never

RUN \
	apk update && \
	apk upgrade -a && \
	build_pkgs="uv build-base libffi-dev openssl-dev python3-dev git" && \
	apk --no-cache add python3 ${build_pkgs} && \
	#git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /opt/log4j-scan && \
	git clone --depth 1 ${GIT_URL} /opt/log4j-scan && \
	# Sync from the scanner's own pyproject.toml and uv.lock rather than a copy
	# of its dependency list kept here. Upstream pins security-patched floors
	# for the transitive deps, and there is nothing to drift out of step with.
	# It sets package = false, so uv installs the dependencies only.
	cd /opt/log4j-scan && \
	uv sync --frozen --no-dev --python /usr/bin/python3 && \
	rm -rf /opt/log4j-scan/.git && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf


# ----------------------------------------------------------------------------


# Same digest as the build stage: the venv hardcodes lib/python3.X, so a
# different Python minor version here would silently break it.
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:10b76ac1c893c93b8db0c741d0439cf2eee48cff9de40879ed735178e2fc1547

WORKDIR /opt/log4j-scan

COPY --from=build /opt/venv /opt/venv
COPY --from=build /opt/log4j-scan /opt/log4j-scan

ENV PATH="/opt/venv/bin:${PATH}"

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/log4j-scan"
LABEL org.opencontainers.image.description="A fully automated, accurate, and extensive scanner for finding vulnerable log4j hosts"

# Runtime install, smoke test and bytecode strip share one layer. A strip in a
# later layer reclaims nothing - the bytecode still sits in the apk layer - and
# running the smoke test after the strip would write __pycache__ back.
# "python" resolves to the venv interpreter, which is what the ENTRYPOINT uses.
RUN \
	apk update && \
	apk upgrade -a && \
	runtime_pkgs="ca-certificates openssl python3" && \
	apk --no-cache add ${runtime_pkgs} && \
	python -c 'import requests, Crypto, termcolor; print(requests.__version__)' && \
	python /opt/log4j-scan/log4j-scan.py -h > /dev/null && \
	rm -rf /var/cache/apk/* && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
	find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

ENTRYPOINT ["python","/opt/log4j-scan/log4j-scan.py"]
CMD ["-h"]
