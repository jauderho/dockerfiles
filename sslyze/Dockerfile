# uv publishes linux/amd64 and linux/arm64 only. This image ships linux/amd64;
# anything wider needs the release tarball per TARGETARCH.
FROM ghcr.io/astral-sh/uv:0.12.7@sha256:95f2aa1fe59274951cfe9b0cbc7972e879ff1004bc8945d130a32eb0dbd85945 AS uv

FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b AS build

ARG BUILD_VERSION
ARG DEBIAN_FRONTEND=noninteractive

ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
	UV_NO_CACHE=1 \
	UV_LINK_MODE=copy \
	UV_PYTHON_DOWNLOADS=never

COPY --from=uv /uv /usr/local/bin/uv
COPY pyproject.toml uv.lock ./

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	# ca-certificates: git verifies TLS with the system trust store, and
	# --no-install-recommends leaves it out otherwise. uv itself does not need
	# it - it ships its own roots - so only the git fetch would fail.
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends python3 ca-certificates git && \
	# --no-install-project: this project only declares dependencies, there is
	# no package here to build. --frozen installs uv.lock exactly as written,
	# which already encodes the override-dependencies entry lifting sslyze's
	# cryptography<47 cap - so the pip --no-deps trick is no longer needed.
	uv sync --frozen --no-install-project --no-dev --python /usr/bin/python3 && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf


# ----------------------------------------------------------------------------


# Same digest as the build stage: the venv hardcodes lib/python3.X, so a
# different Python minor version here would silently break it.
FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=build /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:${PATH}"

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/sslyze"
LABEL org.opencontainers.image.description="SSLyze is a fast and powerful SSL/TLS scanning library"

# Runtime install, smoke test and bytecode strip share one layer: running the
# smoke test after a separate strip would write __pycache__ straight back.
RUN apt-get update && \
	apt-get dist-upgrade -y && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends python3 && \
	sslyze -h > /dev/null && \
	python3 -c 'import sslyze, cryptography; print(cryptography.__version__)' && \
	rm -rf /usr/bin/pebble && \
	apt-get autoremove -y --purge && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf

ENTRYPOINT ["sslyze"]
CMD ["-h"]
