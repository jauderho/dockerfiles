FROM golang:1.20.2-alpine3.17@sha256:87734b78d26a52260f303cf1b40df45b0797f972bd0250e56937c42114bf472c AS build

WORKDIR /go/src/github.com/shopify/toxiproxy

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/shopify/toxiproxy/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/toxiproxy.tar.gz \
	&& tar xzf /tmp/toxiproxy.tar.gz --strip 1 -C /go/src/github.com/shopify/toxiproxy \ 
	&& go build -o toxiproxy -v -trimpath -buildmode=pie -ldflags="-s -w -X github.com/Shopify/toxiproxy/v2.Version=${BUILD_VERSION}" ./cmd/server \
	&& go build -o toxiproxy-cli -v -trimpath -buildmode=pie -ldflags="-s -w" ./cmd/cli 

# Validation check
RUN cp toxiproxy /go/bin/toxiproxy
RUN cp toxiproxy-cli /go/bin/toxiproxy-cli



# ----------------------------------------------------------------------------



#FROM scratch
FROM alpine:3.17.3@sha256:124c7d2707904eea7431fffe91522a01e5a861a624ee31d03372cc1d138a3126

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/toxiproxy"
LABEL org.opencontainers.image.description="toxiproxy is a framework for simulating network conditions"

RUN apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates \
	&& update-ca-certificates \
	&& rm -rf /var/cache/apk/*

COPY --from=build /go/bin/toxiproxy /toxiproxy
COPY --from=build /go/bin/toxiproxy-cli /toxiproxy-cli

#WORKDIR /toxiproxy

EXPOSE 8474

ENTRYPOINT ["/toxiproxy"]
CMD ["-host=0.0.0.0"]
#CMD ["toxiproxy"]

