FROM ghcr.io/jauderho/golang:1.25.5-alpine3.23@sha256:af19078930f6ab508355e5ed169253d7c862153fe2ccefec67e4eacd3c1d5c84 AS build
#FROM ghcr.io/jauderho/golang:1.24.5-alpine3.22@sha256:1ee281925d91a253c035e34b04fbb7cd78177933a64432ad868abdf6421ffdbd AS build

WORKDIR /go/src/github.com/opentofu/opentofu

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/opentofu/opentofu/archive/
ARG GIT_URL=https://github.com/opentofu/opentofu.git

ENV GO111MODULE on
ENV CGO_ENABLED 1

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
FROM ghcr.io/jauderho/alpine:3.23.2@sha256:dbfce411d28db252736392199ad89977bb514729a0dcd3737bd1d24e17d6d6db

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

