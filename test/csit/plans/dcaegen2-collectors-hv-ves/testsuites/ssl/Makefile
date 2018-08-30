FILE=sample
CA_PASSWD=onap
SUBJ=/C=PL/ST=DL/L=Wroclaw/O=Nokia/OU=MANO
CA=trust

sign: $(FILE).crt

clean:
	rm -f *.crt *.key *.srl *.csr

generate-ca-certificate: $(CA).crt

generate-private-key: $(FILE).key

create-public-key: $(FILE).pub

create-sign-request: $(FILE).csr

$(CA).crt:
	openssl req -new -x509 -keyout $(CA).key -out $(CA).crt -days 365 -passout pass:$(CA_PASSWD) -subj "$(SUBJ)"

$(FILE).key:
	openssl genpkey -algorithm RSA -out $(FILE).key -pkeyopt rsa_keygen_bits:2048

$(FILE).pub: $(FILE).key
	openssl x509 -req -days 360 -in client.csr -CA $(CA).crt -CAkey $(CA).key -CAcreateserial -out client.crt

$(FILE).csr: $(FILE).key
	openssl req -new -sha256 -key $(FILE).key -out $(FILE).csr -subj "$(SUBJ)"

$(FILE).crt: $(CA).crt $(FILE).csr
	openssl x509 -req -days 360 -in $(FILE).csr -CA $(CA).crt -CAkey $(CA).key -out $(FILE).crt -CAcreateserial -passin pass:$(CA_PASSWD)