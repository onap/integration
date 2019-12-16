#!/usr/bin/env python
from __future__ import print_function
import sysrepo as sr
import sys
from pnf import PMFileGenerator
import os

def print_change(op, old_val, new_val):
    if op == sr.SR_OP_CREATED:
        print("CREATED: %s" % new_val.to_string())
        element = new_val.to_string()
        subscriptionName = "sub1"
        if subscriptionName in element:
            print("********************Sending File Ready Event*******************")
            VES_IP = "10.209.57.227"
            VES_PORT = "30235"
            script_dir = os.path.dirname(__file__)
            rel_path = "FileReadyEvent.json"
            fileReadyEventPath = os.path.join(script_dir,rel_path)
            pnf = PMFileGenerator()
            pnf.sendFileReadyEvent(fileReadyEventPath,VES_IP,VES_PORT)

    elif op == sr.SR_OP_DELETED:
        print("DELETED: %s" % old_val.to_string())
    elif op == sr.SR_OP_MODIFIED:
        print("MODIFIED: %s to %s" % (old_val.to_string(), new_val.to_string()))
    elif op == sr.SR_OP_MOVED:
        print("MOVED: %s after %s" % (new_val.xpath(), old_val.xpath()))

def module_change_cb(sess, module_name, event, private_ctx):
    try:
        print("========== CHANGES: =============================================")

        change_path = "/" + module_name + ":*"

        it = sess.get_changes_iter(change_path)
        change = sess.get_change_next(it)
        if event == sr.SR_EV_APPLY:
            print_change(change.oper(), change.old_val(), change.new_val())

        print("========== END OF CHANGES =======================================")
    except Exception as e:
        print(e)
    return sr.SR_ERR_OK


def main():
    try:
        module_name = "pnf-subscriptions"
        print(module_name)
        conn = sr.Connection(module_name)
        sess = sr.Session(conn)
        subscribe = sr.Subscribe(sess)
        subscribe.module_change_subscribe(module_name, module_change_cb)
        try:
            print_current_config(sess, module_name)
        except Exception as e:
            print(e)
        print("========== STARTUP CONFIG APPLIED AS RUNNING ==========")

        sr.global_loop()

        print("Application exit requested, exiting.")

    except Exception as e:
        print(e)


if __name__ == '__main__':
    main()
