###
# ============LICENSE_START=======================================================
# Simulator
# ================================================================================
# Copyright (C) 2019 Nokia. All rights reserved.
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
# ============LICENSE_END=========================================================
###

import sysrepo as sr
import sys
import json
import time
import logging
from kafka import KafkaProducer
from enum import Enum

logging.basicConfig(filename='netopeer_change_saver.log', level=logging.DEBUG)

kafka_producer = None
topic = "config"


class OperationType(Enum):
    CREATED = sr.SR_OP_CREATED
    DELETED = sr.SR_OP_DELETED
    MODIFIED = sr.SR_OP_MODIFIED
    MOVED = sr.SR_OP_MOVED


def module_change_callback(session, name, event, private_ctx):
    if sr.SR_EV_APPLY == event:
        change_path = "/{}:*".format(name)
        changes = session.get_changes_iter(change_path)
        change = session.get_change_next(changes)
        while change:
            try:
                process_change(change)
                change = session.get_change_next(changes)
            except Exception:
                logging.exception("Exception occured")

    return sr.SR_ERR_OK


def process_change(change):
    if change:
        message = {"type": OperationType(change.oper()).name}
        if change.old_val():
            message["old"] = {"path": change.old_val().xpath(), "value": change.old_val().val_to_string()}
        if change.new_val():
            message["new"] = {"path": change.new_val().xpath(), "value": change.new_val().val_to_string()}
        send_message(message)


def send_message(message):
    logging.debug("Message to kafka : %s", message)
    response = kafka_producer.send(topic, message)
    logging.info(response.get(timeout=90))


def create_producer(server):
    for i in range(10): # pylint: disable=W0612
        try:
            return KafkaProducer(bootstrap_servers=server, value_serializer=lambda v: json.dumps(v).encode('utf-8'))
        except Exception:
            time.sleep(15)
    raise Exception("Could not connect to kafka server")


def print_current_config(kafka_session, module):
    name = "/{}:*//*".format(module)
    logging.info("Retrieving current config for %s module", name)
    values = kafka_session.get_items(name)
    for i in range(values.val_cnt()):
        logging.info(values.val(i).to_string())


if __name__ == "__main__":
    try:
        module_name = sys.argv[1]
        bootstrap_servers = sys.argv[2]
        topic = sys.argv[3]
        connection = sr.Connection("example_application2")
        session = sr.Session(connection)
        subscribe = sr.Subscribe(session)
        subscribe.module_change_subscribe(module_name, module_change_callback)

        print_current_config(session, module_name)

        kafka_producer = create_producer(bootstrap_servers)

        sr.global_loop()
    except Exception as e:
        logging.exception("Exception occured")
        raise e
