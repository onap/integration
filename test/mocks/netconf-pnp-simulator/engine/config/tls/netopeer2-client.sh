#!/bin/bash

# ============LICENSE_START=======================================================
#  Copyright (C) 2020 Nordix Foundation.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

# Performs a smoke-test of the NETCONF-Pnp-Simulator by establishing a TLS
# connection and sending a dummy NETCONF Hello Message.

set -euxo pipefail

SERVER_HOST=localhost
SERVER_PORT=6513

SCRIPT_PATH=$(dirname $(realpath -s $0))

CLIENT_CERT="
-----BEGIN CERTIFICATE-----
MIIECTCCAvGgAwIBAgIBBzANBgkqhkiG9w0BAQsFADCBjDELMAkGA1UEBhMCQ1ox
FjAUBgNVBAgMDVNvdXRoIE1vcmF2aWExDTALBgNVBAcMBEJybm8xDzANBgNVBAoM
BkNFU05FVDEMMAoGA1UECwwDVE1DMRMwEQYDVQQDDApleGFtcGxlIENBMSIwIAYJ
KoZIhvcNAQkBFhNleGFtcGxlY2FAbG9jYWxob3N0MB4XDTE1MDczMDA3MjcxOFoX
DTM1MDcyNTA3MjcxOFowgYUxCzAJBgNVBAYTAkNaMRYwFAYDVQQIDA1Tb3V0aCBN
b3JhdmlhMQ8wDQYDVQQKDAZDRVNORVQxDDAKBgNVBAsMA1RNQzEXMBUGA1UEAwwO
ZXhhbXBsZSBjbGllbnQxJjAkBgkqhkiG9w0BCQEWF2V4YW1wbGVjbGllbnRAbG9j
YWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAueCQaNQWoNmF
K6LKu1p8U8ZWdWg/PvDdLsJyzfzl/Qw4UA68SfFNaY06zZl8QB9W02nr5kWeeMY0
VA3adrPgOlvfx3oWlFbkETnMaN4OT3WTQ0Wt6jAWZDzVfopwpJPAzRPxACDftIqF
GagYcF32hZlVNqqnVdbXh0S0EViweqp/dbG4VDUHSNVbglc+u4UbEzNIFXMdEFsJ
ZpkynOmSiTsIATqIhb+2srkVgLwhfkC2qkuHQwAHdubuB07ObM2z01UhyEdDvEYG
HwtYAGDBL2TAcsI0oGeVkRyuOkV0QY0UN7UEFI1yTYw+xZ42HgFx3uGwApCImxhb
j69GBYWFqwIDAQABo3sweTAJBgNVHRMEAjAAMCwGCWCGSAGG+EIBDQQfFh1PcGVu
U1NMIEdlbmVyYXRlZCBDZXJ0aWZpY2F0ZTAdBgNVHQ4EFgQUXGpLeLnh2cSDARAV
A7KrBxGYpo8wHwYDVR0jBBgwFoAUc1YQIqjZsHVwlea0AB4N+ilNI2gwDQYJKoZI
hvcNAQELBQADggEBAJPV3RTXFRtNyOU4rjPpYeBAIAFp2aqGc4t2J1c7oPp/1n+l
ZvjnwtlJpZHxMM783e2ryDQ6dkvXDf8kpwKlg3U3mkJ3xKkDdWrM4QwghXdCN519
aa9qmu0zdFL+jUAaWlQ5tsceOrvbusCcbMqiFGk/QfpHqPv52SVWbYyUx7IX7DE+
UjgsLHycfV/tlcx4ZE6soTzl9VdgSL/zmzG3rjsr58J80rXckLgBhvijgBlIAJvW
fC7D0vaouvBInSFXymdPVoUDZ30cdGLf+hI/i/TfsEMOinLrXVdkSGNo6FXAHKSv
XeB9oFKSzhQ7OPyRyqvEPycUSw/qD6FVr80oDDc=
-----END CERTIFICATE-----
"

CLIENT_KEY="
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAueCQaNQWoNmFK6LKu1p8U8ZWdWg/PvDdLsJyzfzl/Qw4UA68
SfFNaY06zZl8QB9W02nr5kWeeMY0VA3adrPgOlvfx3oWlFbkETnMaN4OT3WTQ0Wt
6jAWZDzVfopwpJPAzRPxACDftIqFGagYcF32hZlVNqqnVdbXh0S0EViweqp/dbG4
VDUHSNVbglc+u4UbEzNIFXMdEFsJZpkynOmSiTsIATqIhb+2srkVgLwhfkC2qkuH
QwAHdubuB07ObM2z01UhyEdDvEYGHwtYAGDBL2TAcsI0oGeVkRyuOkV0QY0UN7UE
FI1yTYw+xZ42HgFx3uGwApCImxhbj69GBYWFqwIDAQABAoIBAQCZN9kR8DGu6V7y
t0Ax68asL8O5B/OKaHWKQ9LqpVrXmikZJOxkbzoGldow/CIFoU+q+Zbwu9aDa65a
0wiP7Hoa4Py3q5XNNUrOQDyU/OYC7cI0I83WS0lJ2zOJGYj8wKae5Z81IeQFKGHK
4lsy1OGPAvPRGh7RjUUgRavA2MCwe07rWRuDb/OJFe4Oh56UMEjwMiNBtMNtncog
j1vr/qgRJdf9tf0zlJmLvUJ9+HSFFV9I/97LJyFhb95gAfHkjdVroLVgT3Cho+4P
WtZaKCIGD0OwfOG2nLV4leXvRUk62/LMlB8NI9+JF7Xm+HCKbaWHNWC7mvWSLV58
Zl4AbUWRAoGBANyJ6SFHFRHSPDY026SsdMzXR0eUxBAK7G70oSBKKhY+O1j0ocLE
jI2krHJBhHbLlnvJVyMUaCUOTS5m0uDw9hgSsAqeSL3hL38kxVZw+KNG9Ouno1Fl
KnE/xXHlPQyeGs/P8nAMzHZxQtEsQdQayJEhK2XXHTsy7Q3MxDisfVJ1AoGBANfD
34gB+OMx6pwj7zk3qWbYXSX8xjCZMR0ciko+h4xeMP2N8B0oyoqC+v1ABMAtJ3wG
sGZd0hV9gwM7OUM3SEwkn6oeg1GemWLcn4rlSmTnZc4aeVwrEWlnSNFX3s4g9l4u
k8Ugu4MVJYqH8HuDQ5Ggl6/QAwPzMSEdCW0O+jOfAoGAIBRbegC5+t6m7Yegz4Ja
dxV1g98K6f58x+MDsQu4tYWV4mmrQgaPH2dtwizvlMwmdpkh+LNWNtWuumowkJHc
akIFo3XExQIFg6wYnGtQb4e5xrGa2xMpKlIJaXjb+YLiCYqJDG2ALFZrTrvuU2kV
9a5qfqTc1qigvNolTM0iaaUCgYApmrZWhnLUdEKV2wP813PNxfioI4afxlpHD8LG
sCn48gymR6E+Lihn7vuwq5B+8fYEH1ISWxLwW+RQUjIneNhy/jjfV8TgjyFqg7or
0Sy4KjpiNI6kLBXOakELRNNMkeSPopGR2E7v5rr3bGD9oAD+aqX1G7oJH/KgPPYd
Vl7+ZwKBgQDcHyWYrimjyUgKaQD2GmoO9wdcJYQ59ke9K+OuGlp4ti5arsi7N1tP
B4f09aeELM2ASIuk8Q/Mx0jQFnm8lzRFXdewgvdPoZW/7VufM9O7dGPOc41cm2Dh
yrTcXx/VmUBb+/fnXVEgCv7gylp/wtdTGHQBQJHR81jFBz0lnLj+gg==
-----END RSA PRIVATE KEY-----
"

DUMMY_HELLO='<hello xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"/>]]>]]>'

(echo -n "$DUMMY_HELLO"; sleep 1) | \
    openssl s_client -connect $SERVER_HOST:$SERVER_PORT \
    -state \
    -CAfile $SCRIPT_PATH/ca.pem \
    -cert <(echo "$CLIENT_CERT") \
    -key <(echo "$CLIENT_KEY")
