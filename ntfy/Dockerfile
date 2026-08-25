FROM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:acb2ce37623dc9b32cca8e204995298705b7341c4b00bfb9f22db47221ec2927 AS build

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
	&& curl --proto "=https" --proto-redir "=https" -L "${ARCHIVE_URL}${BUILD_VERSION}.tar.gz" -o /tmp/ntfy.tar.gz \
	&& tar xzf /tmp/ntfy.tar.gz --strip 1 -C /go/src/github.com/binwiederhier/ntfy \ 
	&& mkdir server/docs \ 
	&& touch server/docs/dummy \ 
	&& mkdir server/site \ 
	&& touch server/site/dummy \
	&& go get -u golang.org/x/net \
	&& go get -u golang.org/x/crypto golang.org/x/net \
	&& go get -u github.com/golang-jwt/jwt/v4 \
	&& go mod tidy \
	&& CGO_CFLAGS="-D_LARGEFILE64_SOURCE" go build -o ntfy -v -trimpath \
		-tags sqlite_omit_load_extension,osusergo,netgo \
		-ldflags="-s -w -X main.version=${BUILD_VERSION}" .

# Validation check
#RUN cp ntfy /go/bin/ntfy



# ----------------------------------------------------------------------------



#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:ef5927339b32bb8cf4a75ae37951bfc27979be5183802ac1f3446abf4279be42

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

