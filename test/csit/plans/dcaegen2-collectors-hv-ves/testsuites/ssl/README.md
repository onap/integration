# Generating SSL certificates

Typical usage:

```shell
make FILE=client
make FILE=server
```

Will generate CA certificate and signed client and server certificates.

More "low-level" usage:

```shell
make generate-ca-certificate
make generate-private-key FILE=client
make sign FILE=client
```
