import os

HOST = "127.0.0.1"
# Set by tox-docker
SSH_PORT = int(os.environ["NETCONF_PNP_SIMULATOR_830_TCP_PORT"])
TLS_PORT = int(os.environ["NETCONF_PNP_SIMULATOR_6513_TCP_PORT"])
USERNAME = "netconf"
SSH_KEY_FILENAME = "../config/ssh/id_rsa"
