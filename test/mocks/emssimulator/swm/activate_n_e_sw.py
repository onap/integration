#  ============LICENSE_START=======================================================
#  ONAP - SO
#  ================================================================================
#  Copyright (C) 2020 Huawei Technologies Co., Ltd. All rights reserved.
#  ================================================================================
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  ============LICENSE_END=========================================================

import os
import logging
import shutil
import random
import time

import conf
import ems_util


OPERATION_NAME = "activateNESw"
logging.basicConfig(level=logging.INFO, format=conf.LOGGER_FORMAT, filename=ems_util.get_log_file(OPERATION_NAME))
logger = logging.getLogger(OPERATION_NAME)


def do_activate(sw_version_to_be_activated, ne_info):
    """
    return err, reason
    """

    logger.info("swVersionToBeActivated: %s" % sw_version_to_be_activated)

    installed_sw = ne_info.get("installedSw", {})
    if sw_version_to_be_activated in installed_sw:
        target_sw_version = installed_sw[sw_version_to_be_activated]["version"]
    else:
        target_sw_version = sw_version_to_be_activated

    sw_install_dir_in_ne = ems_util.get_install_dir(ne_info['omIP'])
    logger.info("SW has been installed at %s" % sw_install_dir_in_ne)

    if "targetSwVersion" in ne_info:
        if ne_info["targetSwVersion"] != target_sw_version:
            msg = "Conflicted targetVersion with to be activated %s" % target_sw_version
            logger.error(msg)
            return True, msg
        del ne_info["targetSwVersion"]

    old_sw_version = ne_info.get("oldSwVersion", "")

    if target_sw_version != ne_info["currentSwVersion"]:
        ne_info["oldSwVersion"] = ne_info["currentSwVersion"]
        ne_info["currentSwVersion"] = target_sw_version
        ne_info["status"] = conf.STATUS_ACTIVATING
        ems_util.update_ne_info(ne_info)

        if target_sw_version != old_sw_version:
            old_sw_dir = os.path.join(sw_install_dir_in_ne, old_sw_version)
            if old_sw_version and os.path.isdir(old_sw_dir):
                shutil.rmtree(old_sw_dir, ignore_errors=True)

    old_cwd = os.getcwd()
    os.chdir(sw_install_dir_in_ne)
    if os.path.islink(conf.CURRENT_VERSION_DIR):
        os.remove(conf.CURRENT_VERSION_DIR)
    os.symlink(target_sw_version, conf.CURRENT_VERSION_DIR)
    os.chdir(old_cwd)

    if "downloadedSwLocation" in ne_info:
        if os.path.isdir(ne_info["downloadedSwLocation"]):
            shutil.rmtree(ne_info["downloadedSwLocation"], ignore_errors=True)
        del ne_info["downloadedSwLocation"]

    return False, None


def generate_notification(activate_process_id, activate_status, sw_version, failure_reason):
    notification = {
        "objectClass": conf.OBJECT_CLASS,
        "objectInstance": conf.OBJECT_INSTANCE,
        "notificationId": random.randint(1, conf.MAX_INT),
        "eventTime": time.asctime(),
        "systemDN": conf.SYSTEM_DN,
        "notificationType": "notifyActivateNESwStatusChanged",
        "activateProcessId": activate_process_id,
        "activateOperationStatus": activate_status,
        "swVersion": sw_version
    }

    if failure_reason:
        logger.error(failure_reason)
        notification["failureReason"] = failure_reason

    return notification


def activate(sw_version_to_be_activated, ne_id):
    ne_info = ems_util.get_ne_info_from_db_by_id(ne_id)

    activate_process_id = random.randint(1, conf.MAX_INT)
    result = conf.REQ_SUCCESS
    ret_value = {
        "activateProcessId": activate_process_id,
        "result": result
    }

    if not ne_info:
        ret_value["result"] = conf.REQ_FAILURE
        ret_value["reason"] = "Can not find NE %s" % ne_id

        logger.error(ret_value["reason"])
        return ret_value

    err, reason = do_activate(sw_version_to_be_activated, ne_info)

    if not err:
        ne_info["status"] = conf.STATUS_ACTIVATED
        ems_util.update_ne_info(ne_info)

        logger.info("Activate SW success")
        activate_status = "NE_SWACTIVATION_SUCCESSFUL"
    else:
        ret_value["result"] = conf.REQ_FAILURE
        ret_value["reason"] = reason

        logger.error("Activate SW failure, reason: %s" % ret_value["reason"])
        activate_status = "NE_SWACTIVATION_FAILED"

    notification = generate_notification(activate_process_id, activate_status, sw_version_to_be_activated, reason)
    ems_util.send_notification(notification, activate_process_id)

    # for automated software management, there is no listOfStepNumbersAndDurations
    return notification, ret_value
