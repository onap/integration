#!/usr/bin/env python
import sysrepo as sr
import sys
from pnf import PNF
import pnfconfig

def displayChange(op, old_val, new_val):
    if op == sr.SR_OP_CREATED:
        print("-------------> CREATED: %s" % new_val.to_string())
        pnf.sendFileReadyEvent(pnfconfig.fileReadyEventPath,pnfconfig.VES_IP,pnfconfig.VES_PORT)

    elif op == sr.SR_OP_DELETED:
        print("-------------> DELETED: %s" % old_val.to_string())
    elif op == sr.SR_OP_MODIFIED:
        print("-------------> MODIFIED: %s to %s" % (old_val.to_string(), new_val.to_string()))
        element = new_val.to_string()
        administrativeState = "LOCKED"
        if administrativeState in element:
            pnf = PNF()
            pnf.sendFileReadyEvent(pnfconfig.fileReadyEventPath,pnfconfig.VES_IP,pnfconfig.VES_PORT)

    elif op == sr.SR_OP_MOVED:
        print("-------------> MOVED: %s after %s" % (new_val.xpath(), old_val.xpath()))

def module_change_cb(sess, module_name, event, private_ctx):
    try:
        print("*** Start ***")

        change_path = "/" + module_name + ":*"

        it = sess.get_changes_iter(change_path)
        change = sess.get_change_next(it)
        if event == sr.SR_EV_APPLY:
            displayChange(change.oper(), change.old_val(), change.new_val())

        print("*** END ***")
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
