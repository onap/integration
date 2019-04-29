#! /usr/bin/python

import sys
import logging
import requests
import json
from datetime import datetime
import progressbar
import time
import csar_parser
import preload
from vcpecommon import *


class SdcUtils:
    def __init__(self, vcpecommon):
        """
        :param vcpecommon:
        """
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(logging.DEBUG)
        self.vcpecommon = vcpecommon

    def get_service_list(self):
        """
        :return: 
        """

        url = self.vcpecommon.sdc_service_list_url
        self.logger.info(url)
        r = requests.get(url, headers=self.vcpecommon.sdc_get_request_headers, auth=self.vcpecommon.sdc_get_request_userpass)
        self.logger.debug(r)
        data = r.json()

        self.logger.debug('---------------------------------------------------------------')
        self.logger.debug('------- Creation request submitted to SDC, got response --------')
        self.logger.debug('response code = %s' % r.status_code )
        self.logger.debug(json.dumps(data, indent=4, sort_keys=True))
        self.logger.debug('---------------------------------------------------------------')

        for service in data:
            if service['name'].startswith('demoVCPE'):
                self.logger.debug('service name = %s, url = %s' % (service['name'], service['toscaModelURL']))
                self.download_file(self.vcpecommon.sdc_url_prefix + service['toscaModelURL'])

    def get_filename_from_cd(self, cd):
        """
        cd: in the format of Content-Disposition: attachment; filename="service-Demovcpeinfra-csar.csar"
        """
        fname = re.findall('filename="(.+)"', cd)
        self.logger.debug('fname = %s' % fname[0])
        return fname[0]

    def download_file(self, url):
        self.logger.info(url)
        response = requests.get(url, headers=self.vcpecommon.sdc_get_request_headers, auth=self.vcpecommon.sdc_get_request_userpass)
        filename = 'csar/' + self.get_filename_from_cd(response.headers.get('Content-Disposition'))
        open(filename, 'wb').write(response.content)

