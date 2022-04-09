FROM golang:1.18.0-alpine3.15@sha256:a2ca4f4c0828b1b426a3153b068bf32a21868911c57a9fc4dccdc5fbb6553b35 AS build

WORKDIR /go/src/github.com/binwiederhier/ntfy

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/binwiederhier/ntfy/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 1

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl git gcc build-base \
	&& update-ca-certificates \
	&& curl -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/ntfy.tar.gz \
	&& tar xzf /tmp/ntfy.tar.gz --strip 1 -C /go/src/github.com/binwiederhier/ntfy \ 
	&& mkdir server/docs \ 
	&& touch server/docs/dummy \ 
	&& mkdir server/site \ 
	&& touch server/site/dummy \
	&& go build -o ntfy -v -trimpath -buildmode=pie -ldflags="-s -w -X main.version=${BUILD_VERSION}" .

# Validation check
#RUN cp ntfy /go/bin/ntfy



# ----------------------------------------------------------------------------



#FROM scratch
FROM alpine:3.15.4@sha256:4edbd2beb5f78b1014028f4fbb99f3237d9561100b6881aabbf5acce2c4f9454

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/ntfy"
LABEL org.opencontainers.image.description="ntfy is a simple HTTP-based pub-sub notification service"

#COPY --from=build /go/bin/ntfy /ntfy
COPY --from=build /go/src/github.com/binwiederhier/ntfy/ntfy /usr/local/bin/ntfy

ENTRYPOINT ["/usr/local/bin/ntfy"]

