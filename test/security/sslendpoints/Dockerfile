FROM golang:1.13.8 AS build

WORKDIR /opt/onap.local/sslendpoints
COPY . /opt/onap.local/sslendpoints
RUN go mod download
RUN CGO_ENABLED=0 go build -ldflags '-extldflags "-static"'

FROM scratch
COPY --from=build /opt/onap.local/sslendpoints/sslendpoints /bin/sslendpoints
ENTRYPOINT ["/bin/sslendpoints"]
CMD ["--help"]
