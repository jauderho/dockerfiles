FROM ubuntu:21.10@sha256:1108598c6469492b0ec61c4c9bab6868a3d335ecf76deb4d31ff3b2615170ae9
ADD https://github.com/just-containers/s6-overlay/releases/download/v2.1.0.2/s6-overlay-amd64-installer /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer /
RUN apt-get update && \
    apt-get install -y nginx && \
    echo "daemon off;" >> /etc/nginx/nginx.conf
ENTRYPOINT ["/init"]
CMD ["nginx"]
