from common import *

def test_unauthorized():
    '''Check service denies access if
    invalid credentials provided'''

    req = requests.get('{0}'.format(URI_GET_STRING), auth=INVALID_AUTH_STRING)
    assert req.status_code == requests.codes.unauthorized
    assert UNAUTHORIZED_MSG in req.text

    req = requests.put('{0}'.format(URI_PUT_STRING), auth=INVALID_AUTH_STRING,
                       json=MOI_DATA_TMPL)
    assert req.status_code == requests.codes.unauthorized
    assert UNAUTHORIZED_MSG in req.text

    req = requests.patch('{0}'.format(URI_PATCH_STRING),
                         auth=INVALID_AUTH_STRING, json=MOI_DATA_PATCH)
    assert req.status_code == requests.codes.unauthorized
    assert UNAUTHORIZED_MSG in req.text

    req = requests.delete('{0}'.format(URI_DELETE_STRING),
                          auth=INVALID_AUTH_STRING)
    assert req.status_code == requests.codes.unauthorized
    assert UNAUTHORIZED_MSG in req.text
