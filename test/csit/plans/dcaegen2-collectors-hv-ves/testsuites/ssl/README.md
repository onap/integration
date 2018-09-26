# Generating SSL certificates

## Java keytool way (recommended)

To generate:

```shell
./gen-certs.sh
```

To clean (remove generated files):

```shell
./gen-certs.sh clean
```

## OpenSSL way (currently might not work)

> Add `-f Makefile-openssl` to each command

Typical usage:

```shell
make FILE=client
make FILE=server
```

or (to generate PKCS12 key and trust stores):

```shell
make create-key-store FILE=client
make create-key-store FILE=server
make create-trust-store
```

Will generate CA certificate and signed client and server certificates.

More "low-level" usage:

```shell
make generate-ca-certificate
make generate-private-key FILE=client 
make sign FILE=client
```

# Connecting to a server

First generate *client* and *server* certificates. Then start a server with it's cert and make ca.crt a trusted certification authority.

After that you can:

```shell
./connect.sh client localhost:8600 < file_with_a_data_to_be_sent.dat
```
