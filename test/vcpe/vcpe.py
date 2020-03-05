#!/usr/bin/env python

import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(name)s.%(funcName)s(): %(message)s')

import sys
from vcpecommon import * # pylint: disable=W0614
import sdcutils
import soutils
from datetime import datetime
import preload
import vcpe_custom_service
import csar_parser
import config_sdnc_so
import json
import urllib3
import argparse
from collections import OrderedDict

# disable InsecureRequestWarning warning in requests < 2.16.0
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
# disable InsecureRequestWarning warning in requests >= 2.16.0
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

def config_sniro(vcpecommon, vgmux_svc_instance_uuid, vbrg_svc_instance_uuid):
    logger = logging.getLogger(__name__)

    logger.info('\n----------------------------------------------------------------------------------')
    logger.info('Start to config SNIRO homing emulator')

    preloader = preload.Preload(vcpecommon)
    template_sniro_data = vcpecommon.find_file('sniro_data', 'json', 'preload_templates')
    template_sniro_request = vcpecommon.find_file('sniro_request', 'json', 'preload_templates')

    vcperescust_csar = vcpecommon.find_file('rescust', 'csar', 'csar')
    parser = csar_parser.CsarParser()
    parser.parse_csar(vcperescust_csar)
    tunnelxconn_ar_name = None
    brg_ar_name = None
    vgw_name = None
    for model in parser.vnf_models:
        logger.info('modelCustomizationName = %s', model['modelCustomizationName'])
        if 'tunnel' in model['modelCustomizationName'].lower():
            logger.info('tunnel is in %s', model['modelCustomizationName'])
            tunnelxconn_ar_name = model['modelCustomizationName']
        elif 'brg' in model['modelCustomizationName'].lower():
            logger.info('brg is in %s', model['modelCustomizationName'])
            brg_ar_name = model['modelCustomizationName']
        #elif 'vgw' in model['modelCustomizationName']:
        else:
            vgw_name = model['modelCustomizationName']

    if not (tunnelxconn_ar_name and brg_ar_name and vgw_name):
        logger.error('Cannot find all names from %s.', vcperescust_csar)
        sys.exit(1)

    preloader.preload_sniro(template_sniro_data, template_sniro_request, tunnelxconn_ar_name, vgw_name, brg_ar_name,
                            vgmux_svc_instance_uuid, vbrg_svc_instance_uuid)


def create_one_service(vcpecommon, csar_file, vnf_template_file, preload_dict, suffix, heatbridge=False):
    """
    :return:  service instance UUID
    """
    so = soutils.SoUtils(vcpecommon, 'v4')
    return so.create_entire_service(csar_file, vnf_template_file, preload_dict, suffix, heatbridge)


def deploy_brg_only():
    logger = logging.getLogger(__name__)

    vcpecommon = VcpeCommon(cfg_file=args.config)
    preload_dict = vcpecommon.load_preload_data()
#    name_suffix = preload_dict['${brg_bng_net}'].split('_')[-1]
    name_suffix = datetime.now().strftime('%Y%m%d%H%M')

    # create multiple services based on the pre-determined order
    svc_instance_uuid = vcpecommon.load_object(vcpecommon.svc_instance_uuid_file)
    for keyword in ['brgemu']:
        keyword_vnf=keyword + "_"
        keyword_gra=keyword + "gra_"
        heatbridge = 'gmux' == keyword
        csar_file = vcpecommon.find_file(keyword, 'csar', 'csar')
        vnf_template_file = vcpecommon.find_file(keyword_vnf, 'json', 'preload_templates')
        gra_template_file = vcpecommon.find_file(keyword_gra, 'json', 'preload_templates')
        if vcpecommon.gra_api_flag:
            vcpecommon.increase_ip_address_or_vni_in_template(gra_template_file, ['vbrgemu_private_ip_0'])
            svc_instance_uuid[keyword] = create_one_service(vcpecommon, csar_file, gra_template_file, preload_dict,
                                                            name_suffix, heatbridge)
        else:
            vcpecommon.increase_ip_address_or_vni_in_template(vnf_template_file, ['vbrgemu_private_ip_0'])
            svc_instance_uuid[keyword] = create_one_service(vcpecommon, csar_file, vnf_template_file, preload_dict,
                                                            name_suffix, heatbridge)
        if not svc_instance_uuid[keyword]:
            sys.exit(1)

    # Setting up SNIRO
    config_sniro(vcpecommon, svc_instance_uuid['gmux'], svc_instance_uuid['brgemu'])


def deploy_infra():
    logger = logging.getLogger(__name__)

    vcpecommon = VcpeCommon(cfg_file=args.config)

    # preload all VNF-API networks
    network_template = vcpecommon.find_file('network.', 'json', 'preload_templates')
    name_suffix = datetime.now().strftime('%Y%m%d%H%M')
    preloader = preload.Preload(vcpecommon)
    preload_dict = preloader.preload_all_networks(network_template, name_suffix)
    logger.debug('Initial preload dictionary:')
    logger.debug(json.dumps(preload_dict, indent=4, sort_keys=True))
    if not preload_dict:
        logger.error("Failed to preload networks.")
        sys.exit(1)
    vcpecommon.save_preload_data(preload_dict)

    # preload all GRA-API networks
    network_template_gra = vcpecommon.find_file('networkgra.', 'json', 'preload_templates')
    preloader = preload.Preload(vcpecommon)
    preload_dict_gra = preloader.preload_all_networks(network_template_gra, name_suffix)
    logger.debug('Initial preload dictionary:')
    logger.debug(json.dumps(preload_dict, indent=4, sort_keys=True))
    if not preload_dict_gra:
        logger.error("Failed to preload networks.")
        sys.exit(1)
    vcpecommon.save_preload_data(preload_dict_gra)

    # create multiple services based on the pre-determined order
    svc_instance_uuid = {}
    for keyword in ['infra', 'bng', 'gmux', 'brgemu']:
        keyword_vnf=keyword + "_"
        keyword_gra=keyword + "gra_"
        heatbridge = 'gmux' == keyword
        csar_file = vcpecommon.find_file(keyword, 'csar', 'csar')
        vnf_template_file = vcpecommon.find_file(keyword_vnf, 'json', 'preload_templates')
        gra_template_file = vcpecommon.find_file(keyword_gra, 'json', 'preload_templates')
        if vcpecommon.gra_api_flag:
            svc_instance_uuid[keyword] = create_one_service(vcpecommon, csar_file, gra_template_file, preload_dict,
                                                            name_suffix, heatbridge)
        else:
            svc_instance_uuid[keyword] = create_one_service(vcpecommon, csar_file, vnf_template_file, preload_dict,
                                                            name_suffix, heatbridge)
        if not svc_instance_uuid[keyword]:
            sys.exit(1)

    vcpecommon.save_object(svc_instance_uuid, vcpecommon.svc_instance_uuid_file)

    # Setting up SNIRO
    config_sniro(vcpecommon, svc_instance_uuid['gmux'], svc_instance_uuid['brgemu'])

    print('----------------------------------------------------------------------------------------------------')
    print('Congratulations! The following have been completed correctly:')
    print(' - Infrastructure Service Instantiation: ')
    print('     * 4 VMs:      DHCP, AAA, DNS, Web Server')
    print('     * 2 Networks: CPE_PUBLIC, CPE_SIGNAL')
    print(' - vBNG Service Instantiation: ')
    print('     * 1 VM:       vBNG')
    print('     * 2 Networks: BRG_BNG, BNG_MUX')
    print(' - vGMUX Service Instantiation: ')
    print('     * 1 VM:       vGMUX')
    print('     * 1 Network:  MUX_GW')
    print(' - vBRG Service Instantiation: ')
    print('     * 1 VM:       vBRG')
    print(' - Adding vGMUX vServer information to AAI.')
    print(' - SNIRO Homing Emulator configuration.')


def deploy_custom_service():
    nodes = ['brg', 'mux']
    vcpecommon = VcpeCommon(nodes, cfg_file=args.config)
    custom_service = vcpe_custom_service.CustomService(vcpecommon)

    # clean up
    host_dic = {k: vcpecommon.hosts[k] for k in nodes}
    if False:
        if not vcpecommon.delete_vxlan_interfaces(host_dic):
            sys.exit(1)
        custom_service.del_all_vgw_stacks(vcpecommon.vgw_name_keyword)

    #custom_service.clean_up_sdnc()

    # create new service
    csar_file = vcpecommon.find_file('rescust', 'csar', 'csar')
    vgw_template_file = vcpecommon.find_file('vgw', 'json', 'preload_templates')
    vgw_gra_template_file = vcpecommon.find_file('gwgra', 'json', 'preload_templates')
    preload_dict = vcpecommon.load_preload_data()
    custom_service.create_custom_service(csar_file, vgw_template_file, vgw_gra_template_file, preload_dict)


def closed_loop(lossrate=0):
    nodes = ['brg', 'mux']
    logger = logging.getLogger('__name__')
    vcpecommon = VcpeCommon(nodes, cfg_file=args.config)

    logger.info('Setting up closed loop policy')
    policy_template_file = vcpecommon.find_file('operational.vcpe', 'json', 'preload_templates')
    vcpecommon.set_closed_loop_policy(policy_template_file)

    logger.info('Cleaning up vGMUX data reporting settings')
    vcpecommon.del_vgmux_ves_mode()
    time.sleep(2)
    vcpecommon.del_vgmux_ves_collector()

    logger.info('Starting vGMUX data reporting to DCAE')
    time.sleep(2)
    vcpecommon.set_vgmux_ves_collector()

    logger.info('Setting vGMUX to report packet loss rate: %s', lossrate)
    time.sleep(2)
    vcpecommon.set_vgmux_packet_loss_rate(lossrate, vcpecommon.load_vgmux_vnf_name())
    if lossrate > 0:
        print('Now please observe vGMUX being restarted')


def init_so_sdnc():
    logger = logging.getLogger('__name__')
    vcpecommon = VcpeCommon(cfg_file=args.config)
    config_sdnc_so.insert_sdnc_ip_pool(vcpecommon)
    config_sdnc_so.insert_customer_service_to_so(vcpecommon)
    #config_sdnc_so.insert_customer_service_to_sdnc(vcpecommon)
    vgw_vfmod_name_index=  0
    vcpecommon.save_object(vgw_vfmod_name_index, vcpecommon.vgw_vfmod_name_index_file)


def init():
    vcpecommon = VcpeCommon(cfg_file=args.config)
    init_sdc(vcpecommon)
    download_vcpe_service_templates(vcpecommon)
    preloader = preload.Preload(vcpecommon)
    template_aai_region_data = vcpecommon.find_file('aai_region_data', 'json', 'preload_templates')
    preloader.preload_aai_data(template_aai_region_data)


def init_sdc(vcpecommon):
    sdc = sdcutils.SdcUtils(vcpecommon)
    # default SDC creates BRG - remove this in frankfurt
    #sdc.create_allotted_resource_subcategory('BRG')


def download_vcpe_service_templates(vcpecommon):
    sdc = sdcutils.SdcUtils(vcpecommon)
    sdc.download_vcpe_service_template()


def tmp_sniro():
    logger = logging.getLogger(__name__)

    vcpecommon = VcpeCommon(cfg_file=args.config)

    svc_instance_uuid = vcpecommon.load_object(vcpecommon.svc_instance_uuid_file)
    # Setting up SNIRO
    config_sniro(vcpecommon, svc_instance_uuid['gmux'], svc_instance_uuid['brgemu'])


def test():
    vcpecommon = VcpeCommon(cfg_file=args.config)
    print("oom-k8s-04 public ip: %s" % (vcpecommon.get_vm_public_ip_by_nova('oom-k8s-04')))


def get_arg_parser(modes):
    """
    Parse cmd line options and return ArgumentParser object
    :param modes: map of supported script modes
    :return: ArgumentParser object
    """
    # Build usage synopsis string
    usage = "\n"*2
    for k,v in modes.items():
        usage += 'vcpe.py {0:12} {1}\n'.format(k + ':',v)

    parser = argparse.ArgumentParser(usage=usage, formatter_class=
                                     argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('mode',metavar='MODE',
                        help='Script mode: {0}'.format('|'.join(modes.keys())),
                        choices=modes.keys())
    parser.add_argument('--config',help='Configuration file path',default=None)

    return parser

if __name__ == '__main__':
    # Supported modes matrix
    # OrderedDict object has to be used to preserve desired modes
    # order in synopsis text
    modes = OrderedDict()
#    modes["sdc"]      = "Onboard VNFs, design and distribute vCPE services (under development)"
    modes["init"]     = "Add customer service data to SDNC and SO DBs"
    modes["infra"]    = "Deploy infrastructure, including DHCP, AAA, DNS, Web Server, vBNG, vGMUX, vBRG"
    modes["brg"]      = "Deploy brg only (for testing after infra succeeds)"
    modes["customer"] = "Deploy customer service, including vGW and VxLANs"
    modes["loop"]     = "Test closed loop control (packet loss set to 22)"
    modes["noloss"]   = "Set vGMUX packet loss to 0"
    modes["test"]     = ""
    modes["sniro"]    = "Config SNIRO homing emulator"

    parser = get_arg_parser(modes)

    try:
        assert len(sys.argv) != 1
    except AssertionError:
        # No cmd line opts given, print help
        parser.print_help()
        sys.exit(1)
    else:
        args = parser.parse_args()

    if args.mode == 'init':
        init()
        init_so_sdnc()
    elif args.mode == 'infra':
        #if 'y' == raw_input('Ready to deploy infrastructure? y/n: ').lower():
        deploy_infra()
    elif args.mode == 'customer':
        if 'y' == raw_input('Ready to deploy customer service? y/n: ').lower():
            deploy_custom_service()
    elif args.mode == 'loop':
        closed_loop(22)
    elif args.mode == 'noloss':
        closed_loop(0)
    elif args.mode == 'brg':
        deploy_brg_only()
    elif args.mode == 'sniro':
        tmp_sniro()
    elif args.mode == 'test':
        test()
