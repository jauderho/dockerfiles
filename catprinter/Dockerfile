FROM ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b

ARG BUILD_VERSION
ARG GIT_URL=https://github.com/jauderho/catprinter.git

#ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

# requirements.txt now generated from Pipfile
# pipenv lock -r > requirements.txt
COPY requirements.txt . 

RUN \
	apt-get update && \
	apt-get dist-upgrade -y && \
	#build_pkgs="python3-dev git libblas-dev liblapack-dev curl" && \
	# too many packages needed to build catprinter on arm/v7
	#build_pkgs="python3-dev python3-pip git curl libopenblas-dev libblas-dev liblapack-dev patch file gcc g++ gfortran cmake ninja-build libatlas-base-dev libssl-dev" && \
	build_pkgs="python3-dev python3-pip git libblas-dev liblapack-dev curl" && \
	#runtime_pkgs="python3 python3-pip bluez python3-opencv" && \
	#runtime_pkgs="python3 python3-pip bluez libgl1-mesa-glx" && \
	# libxcb1 is the only X library the headless OpenCV build needs, and it is
	# tiny. libglx-mesa0 was here for the GUI build's libGL.so.1, which drags in
	# libllvm21 + mesa-libgallium (~177MB) - and it never actually provided
	# libGL.so.1, so cv2 could not be imported at all.
	runtime_pkgs="python3 bluez libxcb1" && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends ${build_pkgs} ${runtime_pkgs} && \
	python3 -m pip install --no-cache-dir --upgrade pip --ignore-installed --break-system-packages && \
	# --no-deps: requirements.txt is a complete, flat uv export, so nothing more
	# needs resolving. Without it pip re-reads the catprinter sdist's own
	# metadata and installs opencv-python alongside the headless build, which
	# both doubles the OpenCV payload and puts the libGL-linked cv2 back on top.
	pip3 install --no-cache-dir --no-deps -r requirements.txt --break-system-packages && \
	curl -o /usr/local/bin/print.py --proto "=https" --proto-redir "=https" \
		https://raw.githubusercontent.com/jauderho/catprinter/main/print.py && \
	apt-get purge -y ${build_pkgs} && \
	rm -rf /usr/bin/pebble && \
	apt-get autoremove -y --purge && \
	apt-get autoclean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /root/.cache/pip && \
	rm -rf /root/.cargo && \
	# pip was only needed to install requirements.txt; nothing runs it here
	rm -rf /usr/local/lib/python3*/dist-packages/pip \
		/usr/local/lib/python3*/dist-packages/pip-*.dist-info \
		/usr/local/bin/pip /usr/local/bin/pip3* && \
	# udev's hardware database (~22MB) arrives with bluez. bleak reaches BlueZ
	# over D-Bus and no udevd runs in this image, so nothing reads it.
	rm -rf /usr/lib/udev/hwdb.bin /usr/lib/udev/hwdb.d && \
	apt-get clean

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/catprinter"
LABEL org.opencontainers.image.description="catprinter prints to a portable thermal printer sold on AliExpress for around $20"

WORKDIR /work

#RUN pip3 show catprinter
#RUN find /usr/local/lib/python3.11/dist-packages/catprinter-0.1.0.dist-info -print
#RUN chmod 755 /usr/local/bin/print.py

ENTRYPOINT ["python3", "/usr/local/bin/print.py"]
CMD ["-h"]

