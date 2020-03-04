#!/usr/bin/env python

import logging
import requests
import json
from vcpecommon import * # pylint: disable=W0614


class SdcUtils:
    def __init__(self, vcpecommon):
        """
        :param vcpecommon:
        """
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(logging.DEBUG)
        self.vcpecommon = vcpecommon

    def download_vcpe_service_template(self):
        """
        :return: 
        """

        url = self.vcpecommon.sdc_service_list_url
        self.logger.info(url)
        r = requests.get(url, headers=self.vcpecommon.sdc_be_request_headers, auth=self.vcpecommon.sdc_be_request_userpass, verify=False)
        self.logger.debug(r)
        data = r.json()

        self.logger.debug('---------------------------------------------------------------')
        self.logger.debug('------- Creation request submitted to SDC, got response --------')
        self.logger.debug('response code = %s' % r.status_code )
        self.logger.debug(json.dumps(data, indent=4, sort_keys=True))
        self.logger.debug('---------------------------------------------------------------')

        for service in data:
            if (service['name'].startswith('demoVCPE') or service['name'].startswith('vCPEResCust')) and service['distributionStatus'] == 'DISTRIBUTED':
                self.logger.debug('service name = %s, url = %s' % (service['name'], service['toscaModelURL']))
                self.download_file(self.vcpecommon.sdc_be_url_prefix + service['toscaModelURL'])

    def get_filename_from_cd(self, cd):
        """
        cd: in the format of Content-Disposition: attachment; filename="service-Demovcpeinfra-csar.csar"
        """
        fname = re.findall('filename="(.+)"', cd)
        self.logger.debug('fname = %s' % fname[0])
        return fname[0]

    def download_file(self, url):
        self.logger.info(url)
        response = requests.get(url, headers=self.vcpecommon.sdc_be_request_headers, auth=self.vcpecommon.sdc_be_request_userpass, verify=False)
        filename = 'csar/' + self.get_filename_from_cd(response.headers.get('Content-Disposition'))
        open(filename, 'wb').write(response.content)

    def create_allotted_resource_subcategory(self, newSubcategory):
        """
        :param newSubcategory: a new subcategory under Allotted Resource, like BRG
        :return:
        """
        url = self.vcpecommon.sdc_get_category_list_url
        self.logger.info(url)
        resp = requests.get(url, headers=self.vcpecommon.sdc_fe_request_headers, auth=self.vcpecommon.sdc_fe_request_userpass, verify=False)
        data = resp.json()

        self.logger.debug('---------------------------------------------------------------')
        self.logger.debug('------- Creation request submitted to SDC, got response --------')
        self.logger.debug('response code = %s' % resp.status_code )
        self.logger.debug(json.dumps(data, indent=4, sort_keys=True))
        self.logger.debug('---------------------------------------------------------------')

        if data['resourceCategories']:
            for category in data['resourceCategories']:
                if category['name'] == 'Allotted Resource':
                    for subcategory in category['subcategories']:
                        if subcategory['name'] == newSubcategory:
                            self.logger.debug('Subcategory %s already exists' % newSubcategory)
                            return
                    self.logger.debug('Creating a new subcategory %s' % newSubcategory)
                    url = self.vcpecommon.sdc_create_allotted_resource_subcategory_url
                    self.logger.info(url)
                    details = {"name" : newSubcategory}
                    resp = requests.post(url, headers=self.vcpecommon.sdc_fe_request_headers, auth=self.vcpecommon.sdc_fe_request_userpass, json=details, verify=False)
                    self.logger.debug('---------------------------------------------------------------')
                    self.logger.debug('------- Creation subcategory request submitted to SDC, got response --------')
                    self.logger.debug('response code = %s' % resp.status_code )
                    self.logger.debug('---------------------------------------------------------------')



