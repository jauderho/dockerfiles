# uv publishes linux/amd64 and linux/arm64 only. This image ships exactly those
# two platforms; anything wider needs the release tarball per TARGETARCH.
FROM ghcr.io/astral-sh/uv:0.12.9@sha256:8b940d3a9d65bed080436972241af2e21c84b5e8c9193f7014ed71479ee795ff AS uv

FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b AS build

ARG BUILD_VERSION
ARG DEBIAN_FRONTEND=noninteractive

ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
	UV_NO_CACHE=1 \
	UV_LINK_MODE=copy \
	UV_PYTHON_DOWNLOADS=never

COPY --from=uv /uv /usr/local/bin/uv
COPY pyproject.toml uv.lock ./

RUN \
	apt-get update && \
	apt-get dist-upgrade -y && \
	# git: the project depends on catprinter straight from a git ref.
	# curl: fetches print.py, which is copied into the final stage below.
	# ca-certificates: git and curl verify TLS with the system trust store, and
	# --no-install-recommends leaves it out otherwise. uv itself does not need
	# it - it ships its own roots - so only the git and curl steps would fail.
	build_pkgs="python3-dev ca-certificates git libblas-dev liblapack-dev curl" && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends python3 ${build_pkgs} && \
	# --no-install-project: this project only declares dependencies, there is
	# no package here to build. --frozen installs uv.lock exactly as written,
	# which already encodes the override-dependencies entry that drops the GUI
	# opencv-python in favour of opencv-python-headless - so the pip --no-deps
	# trick is no longer needed.
	uv sync --frozen --no-install-project --no-dev --python /usr/bin/python3 && \
	curl -o /usr/local/bin/print.py --proto "=https" --proto-redir "=https" \
		https://raw.githubusercontent.com/jauderho/catprinter/main/print.py && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf


# ----------------------------------------------------------------------------


# Same digest as the build stage: the venv hardcodes lib/python3.X, so a
# different Python minor version here would silently break it.
FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=build /opt/venv /opt/venv
COPY --from=build /usr/local/bin/print.py /usr/local/bin/print.py

ENV PATH="/opt/venv/bin:${PATH}"

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/catprinter"
LABEL org.opencontainers.image.description="catprinter prints to a portable thermal printer sold on AliExpress for around \$20"

# Runtime install, smoke test and bytecode strip share one layer: running the
# smoke test after a separate strip would write __pycache__ straight back.
RUN \
	apt-get update && \
	apt-get dist-upgrade -y && \
	# libxcb1 is the only X library the headless OpenCV build needs, and it is
	# tiny. libglx-mesa0 was here for the GUI build's libGL.so.1, which drags in
	# libllvm21 + mesa-libgallium (~177MB) - and it never actually provided
	# libGL.so.1, so cv2 could not be imported at all.
	runtime_pkgs="python3 bluez libxcb1" && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends ${runtime_pkgs} && \
	python3 -c 'import cv2, numpy, bleak, catprinter; print(cv2.__version__)' && \
	python3 /usr/local/bin/print.py -h > /dev/null && \
	rm -rf /usr/bin/pebble && \
	apt-get autoremove -y --purge && \
	apt-get autoclean && \
	rm -rf /var/lib/apt/lists/* && \
	# udev's hardware database (~22MB) arrives with bluez. bleak reaches BlueZ
	# over D-Bus and no udevd runs in this image, so nothing reads it.
	rm -rf /usr/lib/udev/hwdb.bin /usr/lib/udev/hwdb.d && \
	apt-get clean && \
	find /opt/venv -name '__pycache__' -print0 | xargs -0 -n1 rm -rf

WORKDIR /work

ENTRYPOINT ["python3", "/usr/local/bin/print.py"]
CMD ["-h"]
