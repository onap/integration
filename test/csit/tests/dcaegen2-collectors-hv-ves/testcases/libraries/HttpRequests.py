import requests
from robot.api import logger

valid_status_codes = [
    requests.codes.ok,
    requests.codes.accepted
]


def session_without_env():
    session = requests.Session()
    session.trust_env = False
    return session


def checkStatusCode(status_code, server_name):
    if status_code not in valid_status_codes:
        logger.error("Response status code from " + server_name + ": " + str(status_code))
        raise (Exception(server_name + " returned status code " + status_code))
