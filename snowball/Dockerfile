FROM ubuntu:26.04@sha256:53958ec7b67c2c9355df922dd08dbf0360611f8c3cdb656875e81873db9ffdba

ARG BUILD_VERSION
ARG TARBALL_URL=https://snowball-client.s3.us-west-2.amazonaws.com/latest/snowball-client-linux.tar.gz

# Amazon bundles outdated Java dependencies in the tarball's jarfarm/ that
# generate the bulk of the image's security alerts. Override the worst
# offenders with patched releases from Maven Central. The launcher loads the
# whole jarfarm via a wildcard classpath, so replacing jars in place (keeping
# Amazon's filenames for Netty, which carries its version in pom.properties)
# is transparent. Versions are set in .github/workflows/snowball.yml; bump them
# there as new CVEs land and verify against:
#   gh api /repos/jauderho/dockerfiles/code-scanning/alerts
ARG NETTY_VERSION
ARG BC_VERSION

RUN test -n "${BUILD_VERSION}" && test -n "${NETTY_VERSION}" && test -n "${BC_VERSION}" \
	&& apt-get update \
	&& apt-get dist-upgrade -y \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates curl \
	&& curl -L "${TARBALL_URL}" -o /tmp/snowball.tar.gz \
	&& tar xzf /tmp/snowball.tar.gz --strip 1 -C /usr/local \
	&& rm -rf /tmp/snowball.tar.gz \
	&& cd /usr/local/jarfarm \
	&& for f in netty-*-4.1.jar netty-*-4.1-*.jar; do \
		[ -e "$f" ] || continue; \
		rest=${f%.jar}; artifact=${rest%%-4.1*}; suffix=${rest#*-4.1}; classifier=${suffix#-}; \
		curl -fsSL "https://repo1.maven.org/maven2/io/netty/${artifact}/${NETTY_VERSION}/${artifact}-${NETTY_VERSION}${classifier:+-$classifier}.jar" -o "$f"; \
	done \
	&& for a in bcprov bcpg bcpkix bcutil bcmail bctls; do \
		rm -f "${a}-jdk18on-"*.jar; \
		curl -fsSL "https://repo1.maven.org/maven2/org/bouncycastle/${a}-jdk18on/${BC_VERSION}/${a}-jdk18on-${BC_VERSION}.jar" -o "${a}-jdk18on-${BC_VERSION}.jar"; \
	done \
	&& cd / \
	&& apt-get purge -y curl \
	&& rm -rf /usr/bin/pebble \
	&& apt-get autoremove -y --purge \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/snowball"
LABEL org.opencontainers.image.description="The Snowball Edge Client is used to manage a Snowball device"

# EXPOSE
# ENV
# STOPSIGNAL
HEALTHCHECK NONE
# USER

CMD ["/usr/local/bin/snowballEdge"]

