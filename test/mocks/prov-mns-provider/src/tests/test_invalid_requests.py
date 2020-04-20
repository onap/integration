import pytest
from common import * # pylint: disable=W0614

@pytest.mark.parametrize(('req_method', 'url', 'req_params'), [
    (getattr(requests, 'get'), URI_GET_STRING, {"auth": INVALID_AUTH_STRING}),
    (getattr(requests, 'put'), URI_PUT_STRING, {"auth": INVALID_AUTH_STRING,
                                                "json": MOI_DATA_TMPL}),
    (getattr(requests, 'patch'), URI_PATCH_STRING, {"auth": INVALID_AUTH_STRING,
                                                    "json": MOI_DATA_PATCH}),
    (getattr(requests, 'delete'), URI_DELETE_STRING, {"auth": INVALID_AUTH_STRING})
    ])
def test_unauthorized(req_method, url, req_params):
    '''Check service denies access if
    invalid credentials provided'''
    req = req_method(url, **req_params)
    assert req.status_code == requests.codes.unauthorized
    assert UNAUTHORIZED_MSG in req.text

@pytest.mark.parametrize(('req_method', 'req_params'), [
    (getattr(requests, 'get'), {"auth": AUTH_STRING}),
    (getattr(requests, 'put'), {"auth": AUTH_STRING, "json": MOI_DATA_TMPL}),
    (getattr(requests, 'patch'), {"auth": AUTH_STRING, "json": MOI_DATA_PATCH}),
    (getattr(requests, 'delete'), {"auth": AUTH_STRING})
    ])
def test_bad_moi_class(req_method, req_params):
    '''Check service returns proper
    http code and error msg if MOI class
    is invalid'''
    req = req_method(BAD_CLASS_URI_BASE_STRING, **req_params)
    assert req.status_code == requests.codes.not_acceptable
    assert INVALID_CLASS_MSG in req.text

def test_bad_prefix():
    '''Check service returns proper
    http code and error msg if URI prefix
    is invalid'''

    for url in BAD_PREFIX_URI_BASE_STRING, BAD_PREFIX1_URI_BASE_STRING:
        req = requests.get('{0}'.format(url),
                           auth=AUTH_STRING)
        assert req.status_code == requests.codes.not_found
        assert INVALID_PREFIX_MSG in req.text

        req = requests.put('{0}'.format(url),
                           auth=AUTH_STRING, json=MOI_DATA_TMPL)
        assert req.status_code == requests.codes.not_found
        assert INVALID_PREFIX_MSG in req.text

        req = requests.patch('{0}'.format(url),
                             auth=AUTH_STRING, json=MOI_DATA_PATCH)
        assert req.status_code == requests.codes.not_found
        assert INVALID_PREFIX_MSG in req.text

        req = requests.delete('{0}'.format(url),
                              auth=AUTH_STRING)
        assert req.status_code == requests.codes.not_found
        assert INVALID_PREFIX_MSG in req.text
