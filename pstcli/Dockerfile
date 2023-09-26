FROM almalinux:9.2-minimal@sha256:0240ad1be8c11dda3af295a293e619f9bafcd6041f21c1123c6b5f2698298e49
# FROM rockylinux:9.1-minimal@sha256:9f700bae74355a24f30a7715aeb70d3605746c51776f5ce26486a5ec27243666

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://dl.dell.com/protected/drivers/FOLDER10041193M/1/pstcli-${BUILD_VERSION}.i386.release.rpm

# https://dl.dell.com/protected/drivers/FOLDER10041193M/1/pstcli-3.5.0.0.891.i386.release.rpm

RUN test -n "${BUILD_VERSION}" \
  && microdnf -y upgrade --refresh \ 
  && microdnf -y install libxcrypt-compat \ 
  && curl -H 'user-agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Mobile Safari/537.36' -Lo pstcli-${BUILD_VERSION}.i386.release.rpm "${ARCHIVE_URL}" \
  && rpm -i pstcli-${BUILD_VERSION}.i386.release.rpm \
  && rm -rf pstcli-${BUILD_VERSION}.i386.release.rpm \ 
  && microdnf clean all

# EXPOSE
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
USER nobody

ENTRYPOINT ["pstcli"]

