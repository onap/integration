#!/usr/bin/env python3

import re
import sysrepo as sr
from pnf import PNF


def module_change_cb(sess, module_name, event, private_ctx):
    """  Handle event change based on yang operation. """
    try:
        change_path = "/" + module_name + ":*"
        iterate = sess.get_changes_iter(change_path)
        change = sess.get_change_next(iterate)
        changelist = []
        operation = change.oper()
        pnf = PNF()
        if event == sr.SR_EV_APPLY:
            print("------------------> Start Handle Change <------------------")
            if operation == sr.SR_OP_CREATED:
                while True:
                    change = sess.get_change_next(iterate)
                    if change is None:
                        break
                    changelist.append(change.new_val().to_string())
                result = re.findall(r'\'(.*?)\'', changelist[0])
                jobid = result[0]
                print("Subscription Created : " + changelist[0])
                pnf.create_job_id(jobid, changelist)
                pnf.pm_job()
            elif operation == sr.SR_OP_DELETED:
                changelist.append(change.old_val().to_string())
                result = re.findall(r'\'(.*?)\'', changelist[0])
                jobid = result[0]
                print("Subscription Deleted : " + changelist[0])
                pnf.delete_job_id(jobid)
                pnf.pm_job()
            elif operation == sr.SR_OP_MODIFIED:
                changelist.append(change.new_val().to_string())
                element = changelist[0]
                print("Subscription Modified :" + element)
                result = re.findall(r'\'(.*?)\'', changelist[0])
                jobid = result[0]
                administrative_state = ((element.rsplit('/', 1)[1]).split('=', 1))[1].strip()
                if administrative_state == "LOCKED":
                    pnf.delete_job_id(jobid)
                    pnf.pm_job()
                elif administrative_state == "UNLOCKED":
                    select_xpath = "/" + module_name + ":*//*"
                    values = sess.get_items(select_xpath)
                    if values is not None:
                        for i in range(values.val_cnt()):
                            if jobid in values.val(i).to_string():
                                changelist.append(values.val(i).to_string())
                        pnf.create_job_id(jobid, changelist)
                        pnf.pm_job()
            else:
                print("Unknown Operation")
            print("------------------> End Handle Change <------------------")
    except Exception as error:
        print(error)
    return sr.SR_ERR_OK


def start():
    """ main function to create connection based on moudule name. """
    try:
        module_name = "pnf-subscriptions"
        conn = sr.Connection(module_name)
        sess = sr.Session(conn)
        subscribe = sr.Subscribe(sess)
        subscribe.module_change_subscribe(module_name, module_change_cb)
        sr.global_loop()
        print("Application exit requested, exiting.")
    except Exception as error:
        print(error)


if __name__ == '__main__':
    start()
