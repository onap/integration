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

import logging

import conf
import ems_util


OPERATION_NAME = "upgrade-pre-check"
logging.basicConfig(level=logging.INFO, format=conf.LOGGER_FORMAT, filename=ems_util.get_log_file(OPERATION_NAME))
logger = logging.getLogger(OPERATION_NAME)


def pre_check(pnf_name, old_sw_version, target_sw_version, rule_name, additional_data_file=None):
    logger.info("PreCheck for oldSwVersion: %s, targetSwVersion: %s, ruleName: %s, additionalDataFile: %s" %
                (old_sw_version, target_sw_version, rule_name, additional_data_file))

    ne_info = ems_util.get_ne_info_from_db_by_id(pnf_name)

    if not ne_info:
        ret_value = {
            "result": conf.RESULT_FAILURE,
            "reason": "Can not find NE %s" % pnf_name
        }

        logger.error(ret_value["reason"])
        return ret_value

    current_sw_version_in_db = ne_info.get("currentSwVersion", "")

    if old_sw_version != current_sw_version_in_db:
        ret_value = {
            "result": conf.RESULT_FAILURE,
            "reason": "Current SW version %s in PNF is not matched with oldSwVersion %s" %
                      (current_sw_version_in_db, old_sw_version)
        }

        logger.error(ret_value["reason"])
        return ret_value

    ne_info["checkStatus"] = conf.STATUS_PRECHECKED
    ems_util.update_ne_info(ne_info)
    logger.info("PreCheck SW success, check status: %s" % ne_info["checkStatus"])

    ret_value = {
         "result": conf.RESULT_SUCCESS
    }

    return ret_value
