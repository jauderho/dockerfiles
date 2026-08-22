# Pinned to 1.26.5-alpine3.24: Go 1.26.6 has an internal compiler error (ICE) on
# linux/arm64 in internal/tofu/evaluate.go ("can't find source for ..." in
# (*evaluationStateData).GetResource). Do not bump to 1.26.6 until this is fixed
# upstream; revisit when Go 1.26.7 ships.
FROM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:7e070021291cfb200a9a7e91029ce5f96b76d1015794fab30882689e4c586d5d AS build
#FROM ghcr.io/jauderho/golang:1.27.0-alpine3.24@sha256:7e070021291cfb200a9a7e91029ce5f96b76d1015794fab30882689e4c586d5d AS build

WORKDIR /go/src/github.com/opentofu/opentofu

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/opentofu/opentofu/archive/
ARG GIT_URL=https://github.com/opentofu/opentofu.git

ENV GO111MODULE=on
ENV CGO_ENABLED=1

#COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git gcc build-base libc-dev \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} . \
	#&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/opentofu/opentofu \
	#&& git clone --depth 1 ${GIT_URL} /go/src/github.com/opentofu/opentofu \
	#&& cd /go/src/github.com/opentofu/opentofu \
	&& go install golang.org/x/tools/cmd/stringer@latest \
	#&& go get -u github.com/hashicorp/go-getter github.com/cloudflare/circl google.golang.org/protobuf golang.org/x/net \
	#&& go get -u github.com/hashicorp/go-slug \
	#&& go get -u golang.org/x/crypto golang.org/x/net golang.org/x/tools \
	&& go get -u golang.org/x/crypto golang.org/x/net golang.org/x/tools \
	#&& go get -u ./... \
	&& go mod tidy \
	#&& go install std \
	&& cd $(go env GOROOT)/src \  \
	&& GOOS=linux GOARCH=$(go env GOARCH) CGO_ENABLED=1 go install -v -tags musl std \
	&& cd - \
	&& go generate ./... \
	&& go run ./tools/protobuf-compile . \
	&& go build -v -trimpath -ldflags="-s -w -X github.com/opentofu/opentofu/version.dev=no -X main.experimentsAllowed=yes" ./cmd/tofu \
	&& cp tofu /go/bin/tofu \
	&& go clean && go clean -cache && go clean -modcache 



# ----------------------------------------------------------------------------



#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:ff52f2346776ea44fca133cbd5ec332e5ee10d10cef9c433bbe337e3c31c2a50

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/opentofu"
LABEL org.opencontainers.image.description="opentofu is a tool for building, changing, and versioning infrastructure safely and efficiently"

RUN apk update \
	&& apk upgrade -a 

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /go/bin/tofu /usr/local/bin/tofu

#RUN opentofu --version

ENTRYPOINT [ "/usr/local/bin/tofu" ]

