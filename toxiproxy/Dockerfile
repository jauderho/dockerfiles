FROM golang:1.22.4-alpine3.20@sha256:6522f0ca555a7b14c46a2c9f50b86604a234cdc72452bf6a268cae6461d9000b AS build

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
	&& go get -u all \
	&& go mod tidy \
	&& go build -o toxiproxy -v -trimpath -ldflags="-s -w -X github.com/Shopify/toxiproxy/v2.Version=${BUILD_VERSION}" ./cmd/server \
	&& go build -o toxiproxy-cli -v -trimpath -ldflags="-s -w" ./cmd/cli 

# Validation check
RUN cp toxiproxy /go/bin/toxiproxy
RUN cp toxiproxy-cli /go/bin/toxiproxy-cli



# ----------------------------------------------------------------------------



#FROM scratch
FROM alpine:3.20.1@sha256:b89d9c93e9ed3597455c90a0b88a8bbb5cb7188438f70953fede212a0c4394e0

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

