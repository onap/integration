from common import * # pylint: disable=W0614

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

def test_bad_moi_class():
    '''Check service returns proper
    http code and error msg if MOI class
    is invalid'''

    req = requests.get('{0}'.format(BAD_CLASS_URI_BASE_STRING),
                       auth=AUTH_STRING)
    assert req.status_code == requests.codes.not_acceptable
    assert INVALID_CLASS_MSG in req.text

    req = requests.put('{0}'.format(BAD_CLASS_URI_BASE_STRING),
                       auth=AUTH_STRING, json=MOI_DATA_TMPL)
    assert req.status_code == requests.codes.not_acceptable
    assert INVALID_CLASS_MSG in req.text

    req = requests.patch('{0}'.format(BAD_CLASS_URI_BASE_STRING),
                         auth=AUTH_STRING, json=MOI_DATA_PATCH)
    assert req.status_code == requests.codes.not_acceptable
    assert INVALID_CLASS_MSG in req.text

    req = requests.delete('{0}'.format(BAD_CLASS_URI_BASE_STRING),
                          auth=AUTH_STRING)
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
