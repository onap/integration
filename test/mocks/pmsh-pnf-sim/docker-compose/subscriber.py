#!/usr/bin/env python
from __future__ import print_function

__author__ = "Mislav Novakovic <mislav.novakovic@sartura.hr>"
__copyright__ = "Copyright 2018, Deutsche Telekom AG"
__license__ = "Apache 2.0"

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This sample application demonstrates use of Python programming language bindings for sysrepo library.
# Original c application was rewritten in Python to show similarities and differences
# between the two.
#
# Most notable difference is in the very different nature of languages, c is weakly statically typed language
# while Python is strongly dynamically typed. Python code is much easier to read and logic easier to comprehend
# for smaller scripts. Memory safety is not an issue but lower performance can be expected.
#
# The original c implementation is also available in the source, so one can refer to it to evaluate trade-offs.

import sysrepo as sr
import sys


# Helper function for printing changes given operation, old and new value.
def print_change(op, old_val, new_val):
    if op == sr.SR_OP_CREATED:
        print("CREATED: %s" % new_val.to_string())

    elif op == sr.SR_OP_DELETED:
        print("DELETED: %s" % old_val.to_string())
    elif op == sr.SR_OP_MODIFIED:
        print("MODIFIED: %s to %s" % (old_val.to_string(), new_val.to_string()))
    elif op == sr.SR_OP_MOVED:
        print("MOVED: %s after %s" % (new_val.xpath(), old_val.xpath()))


# Helper function for printing events.
def ev_to_str(ev):
    if ev == sr.SR_EV_VERIFY:
        return "verify"
    elif ev == sr.SR_EV_APPLY:
        return "apply"
    elif ev == sr.SR_EV_ABORT:
        return "abort"
    else:
        return "unknown"


# Function to print current configuration state.
# It does so by loading all the items of a session and printing them out.
def print_current_config(session, module_name):
    select_xpath = "/" + module_name + ":*//*"

    values = session.get_items(select_xpath)

    if values is not None:
        print("========== BEGIN CONFIG ==========")
        for i in range(values.val_cnt()):
            print(values.val(i).to_string(), end='')
        print("=========== END CONFIG ===========")


# Function to be called for subscribed client of given session whenever configuration changes.
def module_change_cb(sess, module_name, event, private_ctx):
    try:
        print("========== Notification " + ev_to_str(event) + " =============================================")
        if event == sr.SR_EV_APPLY:
            print_current_config(sess, module_name)

        print("========== CHANGES: =============================================")

        change_path = "/" + module_name + ":*"

        it = sess.get_changes_iter(change_path)

        while True:
            change = sess.get_change_next(it)
            if change is None:
                break
            print_change(change.oper(), change.old_val(), change.new_val())

        print("========== END OF CHANGES =======================================")
    except Exception as e:
        print(e)

    return sr.SR_ERR_OK


def main():
    # Notable difference between c implementation is using exception mechanism for open handling unexpected events.
    # Here it is useful because `Connection`, `Session` and `Subscribe` could throw an exception.
    try:
        module_name = "pnf-subscriptions"
        if len(sys.argv) > 1:
            module_name = sys.argv[1]
        else:
            print("\nYou can pass the module name to be subscribed as the first argument")

        print("Application will watch for changes in " + module_name)

        # connect to sysrepo
        conn = sr.Connection(module_name)

        # start session
        sess = sr.Session(conn)

        # subscribe for changes in running config */
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
