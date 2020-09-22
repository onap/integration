import pytest
from test_settings import *
from json import load
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

@pytest.fixture(scope="module")
def auth_credentials():
    '''A fixture returning credentials for the simulator request'''
    with open(TEST_AUTH_DB_FILE) as creds:
        return load(creds)

