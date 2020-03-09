import os

HOST = "127.0.0.1"
# Set by tox-docker
# Unexpectedly, tox-docker uses the repository prefix instead of the image name to define the
# variable prefix.
PORT = int(os.environ["LOCALHOST_830_TCP_PORT"])
USERNAME = "netconf"
KEY_FILENAME = "../config/ssh/id_rsa"

DEBUG = False
