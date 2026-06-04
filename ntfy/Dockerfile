FROM ghcr.io/jauderho/golang:1.26.4-alpine3.23@sha256:5ce0672076c925afce621f2859d8f1073640aaa5d24db561c58d40db5042608e AS build

WORKDIR /go/src/github.com/binwiederhier/ntfy

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/binwiederhier/ntfy/archive/

ENV GO111MODULE=on
ENV CGO_ENABLED=1

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
	&& go get -u golang.org/x/net \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go get -u github.com/golang-jwt/jwt/v4 \
	&& go mod tidy \
	&& CGO_CFLAGS="-D_LARGEFILE64_SOURCE" go build -o ntfy -v -trimpath -ldflags="-s -w -X main.version=${BUILD_VERSION}" .

# Validation check
#RUN cp ntfy /go/bin/ntfy



# ----------------------------------------------------------------------------



#FROM scratch
FROM ghcr.io/jauderho/alpine:3.23.4@sha256:e82de71b2f6ff2a9422529e644b3b86d1df91c0c70a3916376af0e67de33b9ce

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

