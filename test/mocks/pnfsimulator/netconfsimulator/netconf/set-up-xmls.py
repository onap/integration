#!/usr/bin/env python

###
# ============LICENSE_START=======================================================
# Simulator
# ================================================================================
# Copyright (C) 2019 Nokia. All rights reserved.
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
# ============LICENSE_END=========================================================
###

import os
import sys
import logging
import logging.config

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Placeholders definition - this needs to match placeholders in
# load_server_certs_xml_file and tls_listen_xml_file
SERVER_KEY_NAME = "SERVER_KEY_NAME"
SERVER_CERT_NAME = "SERVER_CERT_NAME"
SERVER_CERTIFICATE_HERE = "SERVER_CERTIFICATE_HERE"
CA_CERT_NAME = "CA_CERT_NAME"
CLIENT_CERT_NAME = "CLIENT_CERT_NAME"
CLIENT_CERTIFICATE_HERE="CLIENT_CERTIFICATE_HERE"
CA_CERTIFICATE_HERE = "CA_CERTIFICATE_HERE"
CLIENT_FINGERPRINT_HERE = "CLIENT_FINGERPRINT_HERE"
SERVER_CERTIFICATE_ENV = "SERVER_CERTIFICATE_ENV"
CA_CERTIFICATE_ENV = "CA_CERTIFICATE_ENV"


class FileHelper(object):
    @classmethod
    def get_file_contents(cls, filename):
        with open(filename, "r") as f:
            return f.read()

    @classmethod
    def write_file_contents(cls, filename, data):
        with open(filename, "w+") as f:
            f.write(data)


class CertHelper(object):
    @classmethod
    def get_pem_content_stripped(cls, pem_dir, pem_filename):
        cmd = "cat {}/{} | grep -v '^-'".format(pem_dir, pem_filename)
        content = CertHelper.system(cmd)
        return content

    @classmethod
    def get_cert_fingerprint(cls, directory, cert_filename):
        cmd = "openssl x509 -fingerprint -noout -in {}/{} | sed -e " \
              "'s/SHA1 Fingerprint//; s/=//; s/=//p'" \
            .format(directory, cert_filename)
        fingerprint = CertHelper.system(cmd)
        return fingerprint

    @classmethod
    def print_certs_info(cls, ca_cert, ca_fingerprint, server_cert):
        logger.info("Will use server certificate: " + server_cert)
        logger.info("Will use CA certificate: " + ca_cert)
        logger.info("CA certificate fingerprint: " + ca_fingerprint)

    @classmethod
    def system(cls, cmd):
        return os.popen(cmd).read().replace("\n", "")


class App(object):
    @classmethod
    def patch_server_certs(cls, data, server_key_filename_noext,
                           server_cert_filename_noext, ca_cert_filename_noext,
                           server_cert, ca_cert, client_cert_filename_noext, client_cert):
        data = data.replace(SERVER_KEY_NAME, server_key_filename_noext)
        data = data.replace(SERVER_CERT_NAME, server_cert_filename_noext)
        data = data.replace(CA_CERT_NAME, ca_cert_filename_noext)
        data = data.replace(CLIENT_CERT_NAME, client_cert_filename_noext)
        data = data.replace(CLIENT_CERTIFICATE_HERE, client_cert)
        data = data.replace(SERVER_CERTIFICATE_HERE, server_cert)
        data = data.replace(CA_CERTIFICATE_HERE, ca_cert)
        return data

    @classmethod
    def patch_tls_listen(cls, data, server_cert_filename_noext, client_fingerprint,
                         server_cert, ca_cert):
        data = data.replace(SERVER_CERT_NAME, server_cert_filename_noext)
        data = data.replace(CLIENT_FINGERPRINT_HERE, client_fingerprint)
        data = data.replace(SERVER_CERTIFICATE_HERE, server_cert)
        data = data.replace(CA_CERTIFICATE_HERE, ca_cert)
        return data

    @classmethod
    def run(cls):
        # name things
        cert_dir = sys.argv[1]
        ca_cert_filename = sys.argv[2]
        server_cert_filename = sys.argv[3]
        server_key_filename = sys.argv[4]
        load_server_certs_xml_file = sys.argv[5]
        tls_listen_xml_file = sys.argv[6]
        client_cert_filename = sys.argv[7]


        # strip extensions
        ca_cert_filename_noext = ca_cert_filename.replace(".crt", "")
        server_cert_filename_noext = server_cert_filename.replace(".crt", "")
        server_key_filename_noext = server_key_filename.replace(".pem", "")
        client_cert_filename_noext = client_cert_filename.replace(".crt", "")

        # get certificates from files
        server_cert = CertHelper.get_pem_content_stripped(cert_dir,
                                                          server_cert_filename)
        ca_cert = CertHelper.get_pem_content_stripped(cert_dir,
                                                      ca_cert_filename)
        client_fingerprint = CertHelper.get_cert_fingerprint(cert_dir,
                                                             client_cert_filename)
        CertHelper.print_certs_info(ca_cert, client_fingerprint, server_cert)

        client_cert = CertHelper.get_pem_content_stripped(cert_dir,
                                                          client_cert_filename)
        # patch TLS configuration files
        data_srv = FileHelper.get_file_contents(load_server_certs_xml_file)
        patched_srv = App.patch_server_certs(data_srv, server_key_filename_noext,
                                             server_cert_filename_noext,
                                             ca_cert_filename_noext,
                                             server_cert, ca_cert,
                                             client_cert_filename_noext, client_cert)
        FileHelper.write_file_contents(load_server_certs_xml_file, patched_srv)

        data_tls = FileHelper.get_file_contents(tls_listen_xml_file)
        patched_tls = App.patch_tls_listen(data_tls, server_cert_filename_noext,
                                           client_fingerprint, server_cert, ca_cert)
        FileHelper.write_file_contents(tls_listen_xml_file, patched_tls)


def main():
    if len(sys.argv) is not 8:
        print("Usage: {1} <cert_dir> <ca_cert_filename> <server_cert_filename> "
              "<server_key_filename> <load_server_certs_xml_full_path> "
              "<tls_listen_full_path> <client_cert_filename>", sys.argv[0])
        return 1
    App.run()
    logger.info("XML files patched successfully")


if __name__ == '__main__':
    main()
