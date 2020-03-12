#!/usr/bin/env python3

# ============LICENSE_START=======================================================
#  Copyright (C) 2020 Nordix Foundation.
# ================================================================================
#  Modification Copyright 2020 Huawei Technologies Co., Ltd
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

__author__ = "Eliezio Oliveira <eliezio.oliveira@est.tech>"
__copyright__ = "Copyright (C) 2020 Nordix Foundation, and Huawei"
__license__ = "Apache 2.0"

import time
from concurrent.futures import ThreadPoolExecutor
from threading import Timer

import sysrepo as sr

YANG_MODULE_NAME = 'pnf-swm'

#
# ----- BEGIN Finite State Machine definitions -----
#

# Actions
ACT_PRE_CHECK = 'PRE_CHECK'
ACT_DOWNLOAD_NE_SW = 'DOWNLOAD_NE_SW'
ACT_ACTIVATE_NE_SW = 'ACTIVATE_NE_SW'
ACT_CANCEL = 'CANCEL'

# States
ST_CREATED = 'CREATED'
ST_INITIALIZED = 'INITIALIZED'
ST_DOWNLOAD_IN_PROGRESS = 'DOWNLOAD_IN_PROGRESS'
ST_DOWNLOAD_COMPLETED = 'DOWNLOAD_COMPLETED'
ST_ACTIVATION_IN_PROGRESS = 'ACTIVATION_IN_PROGRESS'
ST_ACTIVATION_COMPLETED = 'ACTIVATION_COMPLETED'

# Timeout used for timed transitions
TO_DOWNLOAD = 7
TO_ACTIVATION = 7


def timestamper(sess, key_id):
    xpath = xpath_of(key_id, 'state-change-time')
    now = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    state = sr.Val(now, sr.SR_STRING_T)
    sess.set_item(xpath, state)


def xpath_of(key_id, leaf_id):
    selector = "[neIdentifier='{0}']".format(key_id) if key_id else ''
    return "/%s:software-management/pnf-software-package%s/%s" % (YANG_MODULE_NAME, selector, leaf_id)


"""
The finite state machine (FSM) is represented as a dictionary where the current state is the key, and its value is
an object (also represented as a dictionary) with the following optional attributes:

- on_enter: a function called when FSM enters this state;
- transitions: a dictionary mapping every acceptable action to the target state;
- timed_transition: a pair for a timed transition that will automatically occur after a given interval.
"""
STATE_MACHINE = {
    ST_CREATED: {
        'transitions': {ACT_PRE_CHECK: ST_INITIALIZED}
    },
    ST_INITIALIZED: {
        'on_enter': timestamper,
        'transitions': {ACT_DOWNLOAD_NE_SW: ST_DOWNLOAD_IN_PROGRESS}
    },
    ST_DOWNLOAD_IN_PROGRESS: {
        'on_enter': timestamper,
        'timed_transition': (TO_DOWNLOAD, ST_DOWNLOAD_COMPLETED),
        'transitions': {ACT_CANCEL: ST_INITIALIZED}
    },
    ST_DOWNLOAD_COMPLETED: {
        'on_enter': timestamper,
        'transitions': {ACT_ACTIVATE_NE_SW: ST_ACTIVATION_IN_PROGRESS}
    },
    ST_ACTIVATION_IN_PROGRESS: {
        'on_enter': timestamper,
        'timed_transition': (TO_ACTIVATION, ST_ACTIVATION_COMPLETED),
        'transitions': {ACT_CANCEL: ST_DOWNLOAD_COMPLETED}
    },
    ST_ACTIVATION_COMPLETED: {
        'on_enter': timestamper,
        'transitions': {ACT_ACTIVATE_NE_SW: ST_ACTIVATION_IN_PROGRESS}
    }
}

#
# ----- END Finite State Machine definitions -----
#


def main():
    try:
        conn = sr.Connection(YANG_MODULE_NAME)
        sess = sr.Session(conn)
        subscribe = sr.Subscribe(sess)

        subscribe.module_change_subscribe(YANG_MODULE_NAME, module_change_cb, conn)

        try:
            print_current_config(sess, YANG_MODULE_NAME)
        except Exception as e:
            print(e)

        sr.global_loop()

        print("Application exit requested, exiting.")
    except Exception as e:
        print(e)


# Function to be called for subscribed client of given session whenever configuration changes.
def module_change_cb(sess, module_name, event, private_ctx):
    try:
        conn = private_ctx
        change_path = xpath_of(None, 'action')
        it = sess.get_changes_iter(change_path)
        while True:
            change = sess.get_change_next(it)
            if change is None:
                break
            handle_change(conn, change.oper(), change.old_val(), change.new_val())
    except Exception as e:
        print(e)
    return sr.SR_ERR_OK


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


def handle_change(conn, op, old_val, new_val):
    """
    Handle individual changes on the model.
    """
    if op == sr.SR_OP_CREATED:
        print("CREATED: %s" % new_val.to_string())
        xpath = new_val.xpath()
        last_node = xpath_ctx.last_node(xpath)
        # Warning: 'key_value' modifies 'xpath'!
        key_id = xpath_ctx.key_value(xpath, 'pnf-software-package', 'neIdentifier')
        if key_id and last_node == 'action':
            executor.submit(execute_action, conn, key_id, new_val.data().get_enum())
    elif op == sr.SR_OP_DELETED:
        print("DELETED: %s" % old_val.to_string())
    elif op == sr.SR_OP_MODIFIED:
        print("MODIFIED: %s to %s" % (old_val.to_string(), new_val.to_string()))
    elif op == sr.SR_OP_MOVED:
        print("MOVED: %s after %s" % (new_val.xpath(), old_val.xpath()))


def execute_action(conn, key_id, action):
    sess = sr.Session(conn)
    try:
        cur_state = sess.get_item(xpath_of(key_id, 'current-status')).data().get_enum()
        next_state_str = STATE_MACHINE[cur_state]['transitions'].get(action, None)
        if next_state_str:
            handle_set_state(conn, key_id, next_state_str)
        sess.delete_item(xpath_of(key_id, 'action'))
        sess.commit()
    finally:
        sess.session_stop()


def handle_set_state(conn, key_id, state_str):
    sess = sr.Session(conn)
    try:
        state = sr.Val(state_str, sr.SR_ENUM_T)
        sess.set_item(xpath_of(key_id, 'current-status'), state)
        on_enter = STATE_MACHINE[state_str].get('on_enter', None)
        if on_enter:
            # noinspection PyCallingNonCallable
            on_enter(sess, key_id)
        sess.commit()
        delay, next_state_str = STATE_MACHINE[state_str].get('timed_transition', [0, None])
        if delay:
            Timer(delay, handle_set_state, (conn, key_id, next_state_str)).start()
    finally:
        sess.session_stop()


if __name__ == '__main__':
    xpath_ctx = sr.Xpath_Ctx()
    executor = ThreadPoolExecutor(max_workers=2)
    main()
