#!/usr/bin/env python
import sysrepo as sr
import sys
from pnf import PNF
import pnfconfig
import time
import re

def handleChange(op, old_val, new_val):
    print("------------------> Handle Change <------------------")
    timestemp = time.time()
    pnf = PNF()
    if op == sr.SR_OP_CREATED:
        print("-------------> CREATED: %s" % new_val.to_string())
        result = re.findall(r'\'(.*?)\'', new_val.to_string())
        jobId=result[0]
        pnf.createPMJob(jobId,timestemp)
        pnf.sendFileReadyEvent(pnfconfig.VES_IP,pnfconfig.VES_PORT,timestemp)

    elif op == sr.SR_OP_DELETED:
        print("-------------> DELETED: %s" % old_val.to_string())
    elif op == sr.SR_OP_MODIFIED:
        print("-------------> MODIFIED: %s to %s" % (old_val.to_string(), new_val.to_string()))
        element = new_val.to_string()
        administrativeState = "UNLOCKED"
        if administrativeState in element:
            pnf.createPMJob(jobId,timestemp)
            pnf.sendFileReadyEvent(pnfconfig.VES_IP,pnfconfig.VES_PORT,timestemp)
    elif op == sr.SR_OP_MOVED:
        print("-------------> MOVED: %s after %s" % (new_val.xpath(), old_val.xpath()))

    print("------------------> End Handle Change <------------------")


def module_change_cb(sess, module_name, event, private_ctx):
    try:
        change_path = "/" + module_name + ":*"
        it = sess.get_changes_iter(change_path)
        change = sess.get_change_next(it)
        if event == sr.SR_EV_APPLY:
            handleChange(change.oper(), change.old_val(), change.new_val())
    except Exception as e:
        print(e)
    return sr.SR_ERR_OK


def start():
    try:
        module_name = "pnf-subscriptions"
        conn = sr.Connection(module_name)
        sess = sr.Session(conn)
        subscribe = sr.Subscribe(sess)
        subscribe.module_change_subscribe(module_name, module_change_cb)
        sr.global_loop()
        print("Application exit requested, exiting.")
    except Exception as e:
        print(e)


if __name__ == '__main__':
    start()
