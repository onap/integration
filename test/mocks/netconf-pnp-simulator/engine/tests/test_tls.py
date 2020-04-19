import os
import socket
import ssl
import tarfile
import tempfile
import time
from io import StringIO
from typing import List

import docker
import pytest
from docker.models.containers import Container
from lxml import etree
from ncclient.transport.ssh import MSG_DELIM

import settings

HELLO_DTD = etree.DTD(StringIO("""
<!ELEMENT hello (capabilities, session-id)>
<!ATTLIST hello xmlns CDATA #REQUIRED>
<!ELEMENT capabilities (capability+)>
<!ELEMENT capability (#PCDATA)>
<!ELEMENT session-id (#PCDATA)>
"""))

INITIAL_CONFIG_DIR = "data/tls_initial"
NEW_CONFIG_DIR = "data/tls_new"


class TestTLS:
    container: Container

    @classmethod
    def setup_class(cls):
        dkr = docker.from_env()
        containers = dkr.containers.list(filters={"ancestor": "netconf-pnp-simulator:latest"})
        assert len(containers) == 1
        cls.container = containers[0]

    def test_tls_connect(self):
        nc_connect(INITIAL_CONFIG_DIR)

    @pytest.mark.parametrize("round_id", [f"round #{i + 1}" for i in range(6)])
    def test_tls_reconfiguration(self, round_id):
        self.reconfigure_and_check(NEW_CONFIG_DIR, INITIAL_CONFIG_DIR)
        self.reconfigure_and_check(INITIAL_CONFIG_DIR, NEW_CONFIG_DIR)

    def reconfigure_and_check(self, good_config_dir: str, bad_config_dir: str):
        with simple_tar([f"{good_config_dir}/{b}.pem" for b in ["ca", "server_key", "server_cert"]]) as config_tar:
            status = self.container.put_archive(f"/config/tls", config_tar)
            assert status
        test_start = int(time.time())
        exit_code, (_, err) = self.container.exec_run("/opt/bin/reconfigure-tls.sh", demux=True)
        if exit_code != 0:
            print(f"reconfigure-tls.sh failed with rc={exit_code}")
            log_all("stderr", err)
            log_all("Container Logs", self.container.logs(since=test_start))
            assert False
        nc_connect(good_config_dir)
        # Exception matching must be compatible with Py36 and Py37+
        with pytest.raises(ssl.SSLError, match=r".*\[SSL: CERTIFICATE_VERIFY_FAILED\].*"):
            nc_connect(bad_config_dir)


def log_all(heading: str, lines: object):
    print(f"{heading}:")
    if isinstance(lines, bytes):
        lines = lines.decode("utf-8")
    if isinstance(lines, str):
        lines = lines.split("\n")
    for line in lines:
        print(" ", line)


def simple_tar(paths: List[str]):
    file = tempfile.NamedTemporaryFile()
    with tarfile.open(mode="w", fileobj=file) as tar:
        for path in paths:
            abs_path = os.path.abspath(path)
            tar.add(abs_path, arcname=os.path.basename(path), recursive=False)
    file.seek(0)
    return file


def nc_connect(config_dir: str):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0) as sock:
        context = ssl.create_default_context()
        context.load_verify_locations(f"{config_dir}/ca.pem")
        context.load_cert_chain(certfile=f"{config_dir}/client_cert.pem", keyfile=f"{config_dir}/client_key.pem")
        context.check_hostname = False
        with context.wrap_socket(sock, server_side=False, server_hostname=settings.HOST) as conn:
            conn.connect((settings.HOST, settings.TLS_PORT))
            buf = nc_read_msg(conn)
            print(f"Received NETCONF HelloMessage:\n{buf}")
            conn.close()
            assert buf.endswith(MSG_DELIM)
            hello_root = etree.XML(buf[:-len(MSG_DELIM)])
            valid = HELLO_DTD.validate(hello_root)
            if not valid:
                log_all("Invalid NETCONF <hello> msg", list(HELLO_DTD.error_log.filter_from_errors()))
                assert False


def nc_read_msg(conn: ssl.SSLSocket):
    buf = ''
    while True:
        data = conn.recv(4096)
        if data:
            buf += data.decode(encoding="utf-8")
            if buf.endswith(MSG_DELIM):
                break
        else:
            break
    return buf
