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
import json
import shutil
import random
import time
import tempfile
import zipfile

import conf
import ems_util


OPERATION_NAME = "installNESw"
logging.basicConfig(level=logging.INFO, format=conf.LOGGER_FORMAT, filename=ems_util.get_log_file(OPERATION_NAME))
logger = logging.getLogger(OPERATION_NAME)


def do_install(sw_to_be_installed, ne_info):
    """
    return err, reason, installed_ne_sw
    """

    logger.info("swToBeInstalled: %s" % sw_to_be_installed)

    sw_install_dir_in_ne = ems_util.get_install_dir(ne_info['omIP'])

    if sw_to_be_installed.startswith('/'):
        file_location = sw_to_be_installed
    else:
        sw_download_dir_in_ne = ne_info.get("downloadedSwLocation", "")
        file_location = os.path.join(sw_download_dir_in_ne, sw_to_be_installed)

    if not os.access(file_location, os.R_OK):
        msg = "Missing to be installed SW file %s" % file_location
        logger.error(msg)
        return True, msg, None

    try:
        if not os.path.isdir(sw_install_dir_in_ne):
            os.makedirs(sw_install_dir_in_ne)
    except OSError as e:
        msg = str(e)
        logger.error(msg)
        return True, msg, None

    temp_dir = tempfile.mkdtemp(dir=sw_install_dir_in_ne)
    if file_location.endswith(".zip"):
        with zipfile.ZipFile(file_location) as sw_zip:
            sw_zip.extractall(temp_dir)
    else:
        msg = "Only support zip file"
        logger.error(msg)
        return True, msg, None

    manifest_location = os.path.join(temp_dir, conf.MANIFEST_FILE)
    if os.access(manifest_location, os.R_OK):
        with open(manifest_location) as f_manifest:
            manifest = json.load(f_manifest)
    else:
        shutil.rmtree(temp_dir, ignore_errors=True)
        msg = "Missing manifest file in %s" % file_location
        logger.error(msg)
        return True, msg, None

    try:
        target_sw_name = manifest["name"]
        target_sw_version = manifest["version"]
    except KeyError as e:
        shutil.rmtree(temp_dir, ignore_errors=True)
        msg = "Missing key %s in %s of %s" % (str(e), conf.MANIFEST_FILE, file_location)
        logger.error(msg)
        return True, msg, None

    if "targetSwVersion" in ne_info and ne_info["targetSwVersion"] != target_sw_version:
        shutil.rmtree(temp_dir, ignore_errors=True)
        msg = "Conflicted targetVersion for %s" % file_location
        logger.error(msg)
        return True, msg, None

    ne_info["targetSwVersion"] = target_sw_version
    ems_util.update_ne_info(ne_info)

    target_sw_parent_dir = os.path.join(sw_install_dir_in_ne, target_sw_version)
    try:
        if not os.path.isdir(target_sw_parent_dir):
            os.makedirs(target_sw_parent_dir)
    except OSError as e:
        shutil.rmtree(temp_dir, ignore_errors=True)
        msg = str(e)
        logger.error(msg)
        return True, msg, None

    target_sw_dir = os.path.join(target_sw_parent_dir, target_sw_name)
    if os.path.isdir(target_sw_dir):
        shutil.rmtree(target_sw_dir, ignore_errors=True)

    try:
        shutil.move(temp_dir, target_sw_dir)
    except shutil.Error as e:
        shutil.rmtree(temp_dir, ignore_errors=True)
        msg = str(e)
        logger.error(msg)
        return True, msg, None
    logger.info("Install SW to %s" % target_sw_dir)

    installed_ne_sw = target_sw_name + '-' + target_sw_version
    logger.info("Installed SW: %s" % installed_ne_sw)

    installed_sw_db = os.path.join(target_sw_parent_dir, conf.INSTALLED_SW_FILE)
    if os.path.isfile(installed_sw_db):
        with open(installed_sw_db) as f_installed_sw:
            installed_sw_table = json.load(f_installed_sw)
        if not installed_sw_table:
            installed_sw_table = {}
    else:
        installed_sw_table = {}

    target_sw_info = {
        "name": target_sw_name,
        "version": target_sw_version,
        "installedLocation": target_sw_dir
    }
    installed_sw_table[installed_ne_sw] = target_sw_info

    with open(installed_sw_db, 'w') as f_installed_sw:
        json.dump(installed_sw_table, f_installed_sw, indent=2)

    ne_info["installedSw"] = installed_sw_table

    return False, None, installed_ne_sw


def generate_notification(install_process_id, install_status, installed_ne_sw_info, failed_sw_info):
    notification = {
        "objectClass": conf.OBJECT_CLASS,
        "objectInstance": conf.OBJECT_INSTANCE,
        "notificationId": random.randint(1, conf.MAX_INT),
        "eventTime": time.asctime(),
        "systemDN": conf.SYSTEM_DN,
        "notificationType": "notifyInstallNESwStatusChanged",
        "installProcessId": install_process_id,
        "installOperationStatus": install_status
    }

    if installed_ne_sw_info:
        notification["installedNESwInfo"] = installed_ne_sw_info

    if failed_sw_info:
        notification["failedSwInfo"] = failed_sw_info

    return notification


def install(sw_to_be_installed, ne_id):
    ne_info = ems_util.get_ne_info_from_db_by_id(ne_id)

    install_process_id = random.randint(1, conf.MAX_INT)
    result = conf.REQ_SUCCESS
    ret_value = {
        "installProcessId": install_process_id,
        "result": result
    }

    if not ne_info:
        ret_value["result"] = conf.REQ_FAILURE
        ret_value["reason"] = "Can not find NE %s" % ne_id

        logger.error(ret_value["reason"])
        return ret_value

    ne_info["status"] = conf.STATUS_INSTALLING
    ems_util.update_ne_info(ne_info)

    installed_ne_sw_info = []
    failed_sw_info = []

    err, reason, installed_ne_sw = do_install(sw_to_be_installed, ne_info)

    if not err:
        installed_ne_sw_info.append(installed_ne_sw)
    else:
        result = conf.REQ_FAILURE
        failed_sw_entry = {
            "failedSw": installed_ne_sw,
            "failureReason": reason
        }

        logger.error("Failed installed SW: %s" % str(failed_sw_entry))
        failed_sw_info.append(failed_sw_entry)

    num_installed_ne_sw = len(installed_ne_sw_info)

    if num_installed_ne_sw == 1:
        install_status = "NE_SWINSTALLATION_SUCCESSFUL"
    elif num_installed_ne_sw == 0:
        install_status = "NE_SWINSTALLATION_FAILED"
    else:
        install_status = "NE_SWINSTALLATION_PARTIALLY_SUCCESSFUL"
    logger.info("Install SW status: %s" % install_status)

    notification = generate_notification(install_process_id, install_status, installed_ne_sw_info, failed_sw_info)
    ems_util.send_notification(notification, install_process_id)

    if result == conf.REQ_SUCCESS:
        ems_util.update_ne_info(ne_info)

        logger.info("Install SW success")
    else:
        ret_value["result"] = result
        ret_value["reason"] = json.dumps(failed_sw_info)

        logger.info("Install SW failure, reason: %s" % ret_value["reason"])

    # for automated software management, there is no listOfStepNumbersAndDurations
    return notification, ret_value
