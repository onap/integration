import pytest
from common import * # pylint: disable=W0614

def test_put():
    '''Validate PUT request'''

    MOI_DATA = MOI_DATA_TMPL
    MOI_DATA['data']['id'] = MOI_ID
    MOI_DATA['data']['href'] = '/' + MOI_CLASS + '/' + MOI_ID
    req_put = requests.put('{0}'.format(URI_PUT_STRING), auth=AUTH_STRING,
                          json=MOI_DATA)

    if req_put.status_code != requests.codes.created:
        logger.error('PUT request to {0} failed'.format(URI_PUT_STRING))
        logger.debug('MOI data payload: {0}'.format(dumps(MOI_DATA,indent=2)))
        logger.debug('Response content: {0}'.format(req_put.text))

    assert req_put.status_code == requests.codes.created

@pytest.mark.parametrize(('url', 'req_method', 'req_params'),[
    (URI_GET_STRING, getattr(requests, 'get'), { "auth": AUTH_STRING }),
    (URI_PATCH_STRING, getattr(requests, 'patch'), { "auth": AUTH_STRING,
                                                     "json": MOI_DATA_PATCH}),
    (URI_DELETE_STRING, getattr(requests, 'delete'), { "auth": AUTH_STRING })
    ])
def test_api_methods(url, req_method, req_params):
    '''Valide request'''
    req = req_method(url, **req_params)

    if req.status_code != requests.codes.ok:
        logger.error('{0} request to {1} failed'.format(
                      req_method.__name__.upper(), url))
        logger.debug('Response content: {0}'.format(req.text))

    assert req.status_code == requests.codes.ok
