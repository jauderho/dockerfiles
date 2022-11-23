FROM ubuntu:22.10@sha256:4f9ec2c0aa321966bfe625bc485aa1d6e96549679cfdf98bb404dfcb8e141a7f

ARG BUILD_VERSION

#ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

# requirements.txt now generated from Pipfile
# pipenv lock -r > requirements.txt
COPY requirements.txt . 

RUN \
	apt-get update && \
	#build_pkgs="python3-dev git libblas-dev liblapack-dev curl" && \
	# too many packages needed to build catprinter on arm/v7
	#build_pkgs="python3-dev python3-pip git curl libopenblas-dev libblas-dev liblapack-dev patch file gcc g++ gfortran cmake ninja-build libatlas-base-dev libssl-dev" && \
	build_pkgs="python3-dev python3-pip git libblas-dev liblapack-dev curl" && \
	#runtime_pkgs="python3 python3-pip bluez python3-opencv" && \
	#runtime_pkgs="python3 python3-pip bluez libgl1-mesa-glx" && \
	runtime_pkgs="python3 bluez libgl1-mesa-glx" && \
	DEBIAN_FRONTEND=${DEBIAN_FRONTEND} apt-get install -y --no-install-recommends ${build_pkgs} ${runtime_pkgs} && \
	python3 -m pip install --no-cache-dir --upgrade pip && \
	pip3 install --no-cache-dir -r requirements.txt && \
	pip3 install --no-cache-dir git+https://github.com/jauderho/catprinter.git && \
	curl -o /usr/local/bin/print.py https://raw.githubusercontent.com/jauderho/catprinter/main/print.py && \
	apt-get purge -y ${build_pkgs} && \
	apt-get autoremove -y --purge && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /root/.cache/pip && \
	rm -rf /root/.cargo && \
	apt-get clean

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/catprinter"
LABEL org.opencontainers.image.description="catprinter prints to a portable thermal printer sold on AliExpress for around $20"

WORKDIR /work

#RUN pip3 show catprinter
#RUN find /usr/local/lib/python3.10/dist-packages/catprinter-0.0.0.dist-info -print
#RUN chmod 755 /usr/local/bin/print.py

ENTRYPOINT ["python3", "/usr/local/bin/print.py"]
CMD ["-h"]

