#!/usr/bin/env python

import os
import requests
from vcpecommon import * # pylint: disable=W0614
from datetime import datetime
import soutils
import logging
import preload
import json


class CustomService:
    def __init__(self, vcpecommon):
        self.logger = logging.getLogger(__name__)
        self.vcpecommon = vcpecommon

    # delete all vgw stacks
    def del_all_vgw_stacks(self, keyword):
        param = ' '.join([k + ' ' + v for k, v in self.vcpecommon.cloud.items()])
        openstackcmd = 'openstack ' + param + ' '

        stacks = os.popen(openstackcmd + 'stack list').read()
        found = False
        for stack_description in stacks.split('\n'):
            if keyword in stack_description:
                found = True
                stack_name = stack_description.split('|')[2].strip()
                cmd = openstackcmd + 'stack delete -y ' + stack_name
                self.logger.info('Deleting ' + stack_name)
                os.popen(cmd)

        if not found:
            self.logger.info('No vGW stack to delete')

    # clean up SDNC
    def clean_up_sdnc(self):
        items = ['tunnelxconn-allotted-resources', 'brg-allotted-resources']
        for res in items:
            self.logger.info('Cleaning up ' + res + ' from SDNC')
            requests.delete(self.vcpecommon.sdnc_ar_cleanup_url + res, auth=self.vcpecommon.sdnc_userpass)

    def print_success_info(self, print_instructions=True, nodes=None):
        if not nodes:
            nodes = ['brg', 'mux', 'gw', 'web']
        ip_dict = self.vcpecommon.get_vm_ip(nodes, self.vcpecommon.external_net_addr,
                                            self.vcpecommon.external_net_prefix_len)

        print(json.dumps(ip_dict, indent=4, sort_keys=True))
        for node in ['brg', 'mux']:
            print('VxLAN config in {0}:'.format(node))
            self.vcpecommon.get_vxlan_interfaces(ip_dict[node], print_info=True)

        print(json.dumps(ip_dict, indent=4, sort_keys=True))

        if print_instructions:
            print('----------------------------------------------------------------------------')
            print('Custom service created successfully. See above for VxLAN configuration info.')
            print('To test data plane connectivity, following the steps below.')
            print(' 1. ssh to vGW at {0}'.format(ip_dict['gw']))
            print(' 2. Restart DHCP: systemctl restart isc-dhcp-server')
            print(' 3. ssh to vBRG at {0}'.format(ip_dict['brg']))
            print(' 4. Get IP from vGW: dhclient lstack')
            print(' 5. Add route to Internet: ip route add 10.2.0.0/24 via 192.168.1.254 dev lstack')
            print(' 6. ping the web server: ping {0}'.format('10.2.0.10'))
            print(' 7. wget http://{0}'.format('10.2.0.10'))

    def create_custom_service(self, csar_file, vgw_template_file, vgw_gra_template_file, preload_dict=None):
        name_suffix = datetime.now().strftime('%Y%m%d%H%M')
        brg_mac = self.vcpecommon.get_brg_mac_from_sdnc()
        brg_mac_enc = brg_mac.replace(':', '-')
        # get name index
        self.vgw_vfmod_name_index= self.vcpecommon.load_object(self.vcpecommon.vgw_vfmod_name_index_file)
        self.vgw_vfmod_name_index=self.vgw_vfmod_name_index + 1
        self.vcpecommon.save_object(self.vgw_vfmod_name_index,self.vcpecommon.vgw_vfmod_name_index_file)
        # preload vGW
        if preload_dict:
            preloader = preload.Preload(self.vcpecommon)
            parameters_to_change = ['vgw_private_ip_0', 'vgw_private_ip_1', 'vgw_private_ip_2','vg_vgmux_tunnel_vni']
            self.vcpecommon.increase_ip_address_or_vni_in_template(vgw_template_file, parameters_to_change)
            preloader.preload_vgw(vgw_template_file, brg_mac, preload_dict, name_suffix)
            # preload vGW-GRA
            preloader.preload_vgw_gra(vgw_gra_template_file, brg_mac_enc, preload_dict, name_suffix, str(self.vgw_vfmod_name_index))

        # create service
        so = soutils.SoUtils(self.vcpecommon, 'v5')
        if so.create_custom_service(csar_file, brg_mac, name_suffix):
            self.print_success_info()
