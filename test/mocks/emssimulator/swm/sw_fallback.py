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

import conf
import ems_util


OPERATION_NAME = "swFallback"
logging.basicConfig(level=logging.INFO, format=conf.LOGGER_FORMAT, filename=ems_util.get_log_file(OPERATION_NAME))
logger = logging.getLogger(OPERATION_NAME)


def fallback(ne_info_list):
    logger.info("NE info list: %s" % ne_info_list)

    ne_list = []
    num_failure = 0

    for ne_info in ne_info_list:
        if ne_info.get("status") == conf.STATUS_DOWNLOADING:
            ne_info["status"] = conf.STATUS_ACTIVATED
            ems_util.update_ne_info(ne_info)

            ne_entry = {
                "nEIdentification": ne_info["nEIdentification"],
                "swFallbackStatus": "fallbackSuccessful"
            }
            ne_list.append(ne_entry)
            continue

        sw_install_dir_in_ne = ems_util.get_install_dir(ne_info['omIP'])

        if ne_info.get("status") == conf.STATUS_INSTALLING:
            old_sw_version = ne_info.get("currentSwVersion", "")
            current_sw_version = ne_info.get("targetSwVersion", "")
        else:
            old_sw_version = ne_info.get("oldSwVersion", "")
            current_sw_version = ne_info.get("currentSwVersion", "")

        old_sw_dir = os.path.join(sw_install_dir_in_ne, old_sw_version)

        if not old_sw_version or not os.path.isdir(old_sw_dir):
            ne_entry = {
                "nEIdentification": ne_info["nEIdentification"],
                "swFallbackStatus": "fallbackUnsuccessful"
            }
            logger.error("oldSwVersion (%s) or oldSwDirectory (%s) is none" % (old_sw_version, old_sw_dir))
            ne_list.append(ne_entry)

            num_failure += 1
            continue

        current_sw_dir = os.path.join(sw_install_dir_in_ne, current_sw_version)

        if current_sw_version and os.path.isdir(current_sw_dir) and current_sw_dir != old_sw_dir:
            shutil.rmtree(current_sw_dir, ignore_errors=True)

        old_cwd = os.getcwd()
        os.chdir(sw_install_dir_in_ne)
        if os.path.islink(conf.CURRENT_VERSION_DIR):
            os.remove(conf.CURRENT_VERSION_DIR)
        os.symlink(old_sw_version, conf.CURRENT_VERSION_DIR)
        os.chdir(old_cwd)

        installed_sw_db = os.path.join(old_sw_dir, conf.INSTALLED_SW_FILE)
        if os.path.isfile(installed_sw_db):
            with open(installed_sw_db) as f_installed_sw:
                installed_sw_table = json.load(f_installed_sw)
            if not installed_sw_table:
                installed_sw_table = {}
        else:
            installed_sw_table = {}

        ne_info["installedSw"] = installed_sw_table
        if "oldSwVersion" in ne_info:
            ne_info["currentSwVersion"] = ne_info["oldSwVersion"]
            del ne_info["oldSwVersion"]

        if "targetSwVersion" in ne_info:
            del ne_info["targetSwVersion"]

        if "downloadedSwLocation" in ne_info:
            if os.path.isdir(ne_info["downloadedSwLocation"]):
                shutil.rmtree(ne_info["downloadedSwLocation"], ignore_errors=True)
            del ne_info["downloadedSwLocation"]

        ne_info["status"] = conf.STATUS_ACTIVATED
        ems_util.update_ne_info(ne_info)

        ne_entry = {
            "nEIdentification": ne_info["nEIdentification"],
            "swFallbackStatus": "fallbackSuccessful"
        }
        ne_list.append(ne_entry)

    if num_failure == 0:
        result = conf.RESULT_SUCCESS
    elif num_failure == len(ne_info_list):
        result = conf.RESULT_FAILURE
    else:
        result = conf.RESULT_PARTLY
    logger.info("Fallback SW result: %s" % result)

    ret_value = {
        "nEList": ne_list,
        "result": result
    }

    return ret_value
