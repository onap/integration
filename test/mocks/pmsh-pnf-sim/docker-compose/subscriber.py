#!/usr/bin/env python
import sysrepo as sr
import sys
from pnf import PNF
import time
import re

def module_change_cb(sess, module_name, event, private_ctx):
    try:
        change_path = "/" + module_name + ":*"
        it = sess.get_changes_iter(change_path)
        change = sess.get_change_next(it)
        changelist = []
        operation = change.oper()
        pnf = PNF()
        if event == sr.SR_EV_APPLY:
            print("------------------> Start Handle Change <------------------")
            if operation == sr.SR_OP_CREATED:
                while True:
                    change = sess.get_change_next(it)
                    if change is None:
                        break
                    changelist.append(change.new_val().to_string())
                result = re.findall(r'\'(.*?)\'', changelist[0])
                jobId=result[0]
                print("Subscription Created : " + changelist[0])
                pnf.createJobId(jobId,changelist)
                pnf.pmJob()
            elif operation == sr.SR_OP_DELETED:
                changelist.append(change.old_val().to_string())
                result = re.findall(r'\'(.*?)\'', changelist[0])
                jobId = result[0]
                print("Subscription Deleted : " + changelist[0])
                pnf.deleteJobId(jobId)
                pnf.pmJob()
            elif operation == sr.SR_OP_MODIFIED:
                changelist.append(change.new_val().to_string())
                element = changelist[0]
                print("Subscription Modified :" + element)
                result = re.findall(r'\'(.*?)\'', changelist[0])
                jobId = result[0]
                administrativeState = ((element.rsplit('/',1)[1]).split('=',1))[1].strip()
                if "LOCKED" == administrativeState:
                    pnf.deleteJobId(jobId)
                    pnf.pmJob()
                elif "UNLOCKED" == administrativeState:
                    select_xpath = "/" + module_name + ":*//*"
                    values = sess.get_items(select_xpath)
                    if values is not None:
                        for i in range(values.val_cnt()):
                            if jobId in values.val(i).to_string():
                                changelist.append(values.val(i).to_string())
                        pnf.createJobId(jobId,changelist)
                        pnf.pmJob()
            else:
                print("Unknown Operation")
            print("------------------> End Handle Change <------------------")
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
