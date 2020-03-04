#!/usr/bin/env python

import sys
import logging
import requests
import json

gmux_ip = ''
logging.basicConfig(level=logging.DEBUG, format='%(message)s')
logger = logging.getLogger('')
headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
auth = 'admin', 'admin'
base_url = ''

def list_interface():
    url = base_url
    logger.info(url)
    r = requests.get(url, headers=headers, auth=auth)
    logger.debug(r)
    response = r.json()

    logger.debug('---------------------------------------------------------------')
    logger.debug(json.dumps(response, indent=4, sort_keys=True))
    logger.debug('---------------------------------------------------------------')

def clean_gmux():
    url = base_url
    r = requests.get(url, headers=headers, auth=auth)
    response = r.json()

    interfaces = response.get('interfaces').get('interface')
    for inf in interfaces:
        name = inf.get('name')
        if name.startswith('vxlanTun10'):
            logger.debug('name = {0}'.format(name))
            delete_interface_v3po_l2(name)

    for inf in interfaces:
        name = inf.get('name')
        if name.startswith('vxlanTun10'):
            logger.debug('name = {0}'.format(name))
            delete_interface(name)

def delete_interface_v3po_l2(interface_name):
    url = '{0}/interface/{1}/v3po:l2'.format(base_url, interface_name)
    r = requests.delete(url, headers=headers, auth=auth)
    logger.debug(r)

def delete_interface(interface_name):
    url = '{0}/interface/{1}'.format(base_url, interface_name)
    r = requests.delete(url, headers=headers, auth=auth)
    logger.debug(r)

if __name__ == '__main__':
    gmux_ip = sys.argv[1]
    base_url = 'http://{0}:8183/restconf/config/ietf-interfaces:interfaces'.format(gmux_ip)
    logger.debug('---------------------------------------------------------------')
    logger.debug('list interfaces before cleaning gmux')
    list_interface()
    clean_gmux()
    logger.debug('---------------------------------------------------------------')
    logger.debug('list interfaces after cleaning gmux')
    list_interface()
