FROM golang:1.19.2-alpine3.16@sha256:f3e683657ddf73726b5717c2ff80cdcd9e9efb7d81f77e4948fada9a10dc7257 AS build

WORKDIR /go/src/github.com/shopify/toxiproxy

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/shopify/toxiproxy/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 0

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
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
FROM alpine:3.16.2@sha256:bc41182d7ef5ffc53a40b044e725193bc10142a1243f395ee852a8d9730fc2ad

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/toxiproxy"
LABEL org.opencontainers.image.description="toxiproxy is a framework for simulating network conditions"

#RUN apk add --no-cache ca-certificates \
#	&& update-ca-certificates \
#  && rm -rf /var/cache/apk/*

COPY --from=build /go/bin/toxiproxy /toxiproxy
COPY --from=build /go/bin/toxiproxy-cli /toxiproxy-cli

#WORKDIR /toxiproxy

EXPOSE 8474

ENTRYPOINT ["/toxiproxy"]
CMD ["-host=0.0.0.0"]
#CMD ["toxiproxy"]

