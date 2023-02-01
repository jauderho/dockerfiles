FROM golang:1.20-alpine3.17@sha256:3806fee283c906011b0f498265614cb071224d554342bf8b4bfe663d0e575861 AS build

WORKDIR /go/src/github.com/binwiederhier/ntfy

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/binwiederhier/ntfy/archive/

ENV GO111MODULE on
ENV CGO_ENABLED 1

COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
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
FROM alpine:3.17.1@sha256:f271e74b17ced29b915d351685fd4644785c6d1559dd1f2d4189a5e851ef753a

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/ntfy"
LABEL org.opencontainers.image.description="ntfy is a simple HTTP-based pub-sub notification service"

RUN apk update \
	&& apk upgrade -a

#COPY --from=build /go/bin/ntfy /ntfy
COPY --from=build /go/src/github.com/binwiederhier/ntfy/ntfy /usr/local/bin/ntfy

ENTRYPOINT ["/usr/local/bin/ntfy"]

