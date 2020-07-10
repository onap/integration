#!/usr/bin/env python3

import logging.config
import os
import re

import sysrepo as sr
import yaml

from pnf import PNF

log_file_path = os.path.join(os.path.dirname(__file__), 'app_config/logger_config.yaml')
with open(log_file_path, 'r') as f:
    log_cfg = yaml.safe_load(f.read())
logging.config.dictConfig(log_cfg)
logger = logging.getLogger('dev')


def module_change_cb(sess, module_name, event, private_ctx):
    """  Handle event change based on yang operation. """
    try:
        change_path = f'/{module_name}:*'
        iterate = sess.get_changes_iter(change_path)
        change = sess.get_change_next(iterate)
        changelist = []
        operation = change.oper()
        pnf = PNF()
        if event == sr.SR_EV_APPLY:
            logger.info('------------------> Start Handle Change <------------------')
            if operation == sr.SR_OP_CREATED:
                create_sub(changelist, iterate, pnf, sess)
            elif operation == sr.SR_OP_DELETED:
                delete_sub(change, changelist, pnf)
            elif operation == sr.SR_OP_MODIFIED:
                edit_sub(change, changelist, module_name, pnf, sess)
            else:
                logger.info('Unknown Operation')
            logger.info('------------------> End Handle Change <------------------')
    except Exception as error:
        logger.info(error, exc_info=True)
    return sr.SR_ERR_OK


def edit_sub(change, changelist, module_name, pnf, sess):
    changelist.append(change.new_val().to_string())
    element = changelist[0]
    jobid = get_job_id(changelist)
    administrative_state = ((element.rsplit('/', 1)[1]).split('=', 1))[1].strip()
    if administrative_state == 'LOCKED':
        pnf.delete_job_id(jobid)
        pnf.pm_job()
    elif administrative_state == 'UNLOCKED':
        select_xpath = '/' + module_name + ':*//*'
        values = sess.get_items(select_xpath)
        if values is not None:
            for i in range(values.val_cnt()):
                if jobid in values.val(i).to_string():
                    changelist.append(values.val(i).to_string())
            pnf.create_job_id(jobid, changelist)
            pnf.pm_job()
    logger.info(f'Subscription Modified : {element}')


def create_sub(changelist, iterate, pnf, sess):
    while True:
        change = sess.get_change_next(iterate)
        if change is None:
            break
        changelist.append(change.new_val().to_string())
    jobid = get_job_id(changelist)
    pnf.create_job_id(jobid, changelist)
    pnf.pm_job()
    logger.info(f'Subscription Created : {changelist[0]}')


def delete_sub(change, changelist, pnf):
    changelist.append(change.old_val().to_string())
    jobid = get_job_id(changelist)
    pnf.delete_job_id(jobid)
    pnf.pm_job()
    logger.info(f'Subscription Deleted : {changelist[0]}')


def get_job_id(changelist):
    result = re.findall(r'\'(.*?)\'', changelist[0])
    jobid = result[0]
    return jobid


def start():
    """ main function to create connection based on module name. """
    try:
        module_name = 'pnf-subscriptions'
        conn = sr.Connection(module_name)
        sess = sr.Session(conn)
        subscribe = sr.Subscribe(sess)
        subscribe.module_change_subscribe(module_name, module_change_cb)
        sr.global_loop()
        logger.info('Application exit requested, exiting.')
    except Exception as error:
        logger.error(error, exc_info=True)


if __name__ == '__main__':
    start()
