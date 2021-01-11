FROM golang:1-alpine as build

WORKDIR /go/src/github.com/go-acme/lego/

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/go-acme/lego/archive/

ENV GO111MODULE on

ADD . .

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk add --no-cache ca-certificates curl make git \
	&& curl -L "${ARCHIVE_URL}v${BUILD_VERSION}.tar.gz" -o /tmp/lego.tar.gz \
	&& tar xzf /tmp/lego.tar.gz --strip 1 -C /go/src/github.com/go-acme/lego \
	&& make build

#RUN ls -l /go/src/github.com/go-acme/lego
#RUN make build

RUN cp dist/lego /go/bin/lego
#RUN go build -v -ldflags="-s -w"

# Download go modules
##COPY go.mod .
#COPY go.sum .
#RUN go mod download

#COPY . .
#RUN make build

# ----------------------------------------------------------------------------

FROM alpine

RUN apk update \
    && apk add --no-cache ca-certificates tzdata \
    && update-ca-certificates

COPY --from=build /go/bin/lego /usr/bin/lego

ENTRYPOINT [ "/usr/bin/lego" ]
