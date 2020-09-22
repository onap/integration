from requests import post, codes
from test_settings import *

def test_get_auth_token(auth_credentials):
  url = f"{TEST_REST_URL}{TEST_REST_GET_ACCESS_TOKEN_ENDPOINT}"
  response = post(url, headers=TEST_REST_HEADERS, verify=False, json=auth_credentials[0])
  json_response = response.json()
  assert "accessToken" in json_response
  assert "expires" in json_response
  assert response.status_code == codes.created
