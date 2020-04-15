from common import *

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

def test_get():
    '''Validate GET request'''

    req_get = requests.get('{0}'.format(URI_GET_STRING), auth=AUTH_STRING)

    if req_get.status_code != requests.codes.ok:
        logger.error('GET request to {0} failed'.format(URI_GET_STRING))
        logger.debug('Response content: {0}'.format(req_get.text))

    assert req_get.status_code == requests.codes.ok

def test_patch():
    '''Validate PATCH request'''

    req_patch = requests.patch('{0}'.format(URI_PATCH_STRING),
                               auth=AUTH_STRING, json=MOI_DATA_PATCH)

    if req_patch.status_code != requests.codes.ok:
        logger.error('PATCH request to {0} failed'.format(URI_PATCH_STRING))
        logger.debug('Response content: {0}'.format(req_patch.text))

    assert req_patch.status_code == requests.codes.ok

def test_delete():
    '''Validate DELETE request'''

    req_delete = requests.delete('{0}'.format(URI_DELETE_STRING),
                                 auth=AUTH_STRING)

    if req_delete.status_code != requests.codes.ok:
        logger.error('DELETE request to {0} failed'.format(URI_DELETE_STRING))
        logger.debug('Response content: {0}'.format(req_delete.text))

    assert req_delete.status_code == requests.codes.ok
