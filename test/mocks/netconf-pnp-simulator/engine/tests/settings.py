import os

HOST = "127.0.0.1"
# Set by tox-docker
PORT = int(os.environ["NETCONF_PNP_SIMULATOR_830_TCP_PORT"])
USERNAME = "netconf"
KEY_FILENAME = "../config/ssh/id_rsa"

DEBUG = False
