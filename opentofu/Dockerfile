# Pinned to 1.26.5-alpine3.24: Go 1.26.6 has an internal compiler error (ICE) on
# linux/arm64 in internal/tofu/evaluate.go ("can't find source for ..." in
# (*evaluationStateData).GetResource). Do not bump to 1.26.6 until this is fixed
# upstream; revisit when Go 1.26.7 ships.
FROM ghcr.io/jauderho/golang:1.27.1-alpine3.24@sha256:a404a30fcc7c7537f7215efb6fff6545eccc5d9f474cb49f6daa984f6eaf7683 AS build
#FROM ghcr.io/jauderho/golang:1.27.1-alpine3.24@sha256:a404a30fcc7c7537f7215efb6fff6545eccc5d9f474cb49f6daa984f6eaf7683 AS build

WORKDIR /go/src/github.com/opentofu/opentofu

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/opentofu/opentofu/archive/
ARG GIT_URL=https://github.com/opentofu/opentofu.git

ENV GO111MODULE=on
# Upstream builds all release artifacts with CGO_ENABLED=0 (see .goreleaser.yaml
# and scripts/build.sh), so this matches the official binaries and yields a
# fully static tofu with no libc dependency and no C toolchain in the build.
ENV CGO_ENABLED=0

#COPY . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache ca-certificates curl git \
	&& update-ca-certificates \
	&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} . \
	#&& git clone --depth 1 ${GIT_URL} --branch ${BUILD_VERSION} /go/src/github.com/opentofu/opentofu \
	#&& git clone --depth 1 ${GIT_URL} /go/src/github.com/opentofu/opentofu \
	#&& cd /go/src/github.com/opentofu/opentofu \
	&& go install golang.org/x/tools/cmd/stringer@latest \
	#&& go get -u github.com/hashicorp/go-getter github.com/cloudflare/circl google.golang.org/protobuf golang.org/x/net \
	#&& go get -u github.com/hashicorp/go-slug \
	#&& go get -u golang.org/x/crypto golang.org/x/net golang.org/x/tools \
	&& go get -u golang.org/x/crypto golang.org/x/net golang.org/x/tools golang.org/x/mod google.golang.org/grpc go.opentelemetry.io/otel/sdk go.opentelemetry.io/otel/log go.opentelemetry.io/otel/exporters/otlp/otlplog/otlploggrpc go.opentelemetry.io/otel/exporters/stdout/stdoutlog go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetrichttp go.opentelemetry.io/otel/exporters/otlp/otlplog/otlploghttp github.com/aws/aws-sdk-go-v2/service/s3 github.com/Azure/go-ntlmssp \
	#&& go get -u ./... \
	&& go mod tidy \
	&& go generate ./... \
	&& go run ./tools/protobuf-compile . \
	&& go build -v -trimpath -ldflags="-s -w -X github.com/opentofu/opentofu/version.dev=no -X main.experimentsAllowed=yes" ./cmd/tofu \
	&& cp tofu /go/bin/tofu \
	&& go clean && go clean -cache && go clean -modcache 



# ----------------------------------------------------------------------------



#FROM scratch
FROM ghcr.io/jauderho/alpine:3.24.1@sha256:10b76ac1c893c93b8db0c741d0439cf2eee48cff9de40879ed735178e2fc1547

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

