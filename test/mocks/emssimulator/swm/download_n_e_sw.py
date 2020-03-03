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

import conf
import ems_util


OPERATION_NAME = "downloadNESw"
logging.basicConfig(level=logging.INFO, format=conf.LOGGER_FORMAT, filename=ems_util.get_log_file(OPERATION_NAME))
logger = logging.getLogger(OPERATION_NAME)


def do_download(sw_info, sw_download_dir):
    """
    return err, reason, file_location_in_nes
    """

    sw_location = sw_info['swLocation']

    logger.info("swLocationToBeDownloaded: %s" % sw_location)

    # Use copy file from SW_SERVER_SIMULATOR to simulate download file
    sw_file_name = sw_location.split('/')[-1]

    file_location_in_server = os.path.join(conf.SW_SERVER_SIMULATOR, sw_file_name)
    file_location_in_ne = os.path.join(sw_download_dir, sw_file_name)

    try:
        shutil.copy(file_location_in_server, sw_download_dir)
    except IOError as e:
        msg = "Download %s to %s error: %s" % (sw_file_name, sw_download_dir, str(e))
        logger.error(msg)
        return True, msg, file_location_in_ne

    return False, None, file_location_in_ne


def generate_notification(download_process_id, download_status, downloaded_ne_sw_info, failed_sw_info):
    notification = {
        "objectClass": conf.OBJECT_CLASS,
        "objectInstance": conf.OBJECT_INSTANCE,
        "notificationId": random.randint(1, conf.MAX_INT),
        "eventTime": time.asctime(),
        "systemDN": conf.SYSTEM_DN,
        "notificationType": "notifyDownloadNESwStatusChanged",
        "downloadProcessId": download_process_id,
        "downloadOperationStatus": download_status
    }

    if downloaded_ne_sw_info:
        notification["downloadedNESwInfo"] = downloaded_ne_sw_info

    if failed_sw_info:
        notification["failedSwInfo"] = failed_sw_info

    return notification


def download(sw_to_be_downloaded, ne_id):
    ne_info = ems_util.get_ne_info_from_db_by_id(ne_id)

    download_process_id = random.randint(1, conf.MAX_INT)
    result = conf.REQ_SUCCESS
    ret_value = {
        "downloadProcessId": download_process_id,
        "result": result
    }

    if not ne_info:
        ret_value["result"] = conf.REQ_FAILURE
        ret_value["reason"] = "Can not find NE %s" % ne_id

        logger.error(ret_value["reason"])
        return ret_value

    ne_info["status"] = conf.STATUS_DOWNLOADING
    ems_util.update_ne_info(ne_info)

    num_sw_to_be_downloaded = len(sw_to_be_downloaded)

    downloaded_ne_sw_info = []
    failed_sw_info = []

    sw_download_parent_dir = ems_util.get_download_dir(ne_info['omIP'])
    logger.info("SW will be downloaded to %s" % sw_download_parent_dir)

    sw_download_dir = ne_info.get("downloadedSwLocation", "")
    try:
        if not os.path.isdir(sw_download_parent_dir):
            os.makedirs(sw_download_parent_dir)

        if sw_download_dir and not os.path.isdir(sw_download_dir):
            os.makedirs(sw_download_dir)
    except OSError as e:
        ret_value["result"] = conf.REQ_FAILURE
        ret_value["reason"] = str(e)

        logger.error(ret_value["reason"])
        return ret_value

    if not sw_download_dir:
        sw_download_dir = tempfile.mkdtemp(dir=sw_download_parent_dir)

    for sw_info in sw_to_be_downloaded:
        err, reason, file_location = do_download(sw_info, sw_download_dir)
        if not err:
            logger.info("Downloaded SW file location: %s" % file_location)
            downloaded_ne_sw_info.append(file_location)
        else:
            result = conf.REQ_FAILURE
            failed_sw_entry = {
                "failedSw": file_location,
                "failureReason": reason
            }

            logger.error("Failed downloaded SW: %s" % str(failed_sw_entry))
            failed_sw_info.append(failed_sw_entry)

    num_downloaded_ne_sw = len(downloaded_ne_sw_info)

    if num_downloaded_ne_sw == num_sw_to_be_downloaded:
        download_status = "NE_SWDOWNLOAD_SUCCESSFUL"
    elif num_downloaded_ne_sw == 0:
        download_status = "NE_SWDOWNLOAD_FAILED"
    else:
        download_status = "NE_SWDOWNLOAD_PARTIALLY_SUCCESSFUL"
    logger.info("Download SW status: %s" % download_status)

    notification = generate_notification(download_process_id, download_status, downloaded_ne_sw_info, failed_sw_info)
    ems_util.send_notification(notification, download_process_id)

    if result == conf.REQ_SUCCESS:
        ne_info["downloadedSwLocation"] = sw_download_dir
        ems_util.update_ne_info(ne_info)

        logger.info("Download SW success")
    else:
        shutil.rmtree(sw_download_dir, ignore_errors=True)

        ret_value["result"] = result
        ret_value["reason"] = json.dumps(failed_sw_info)

        logger.info("Download SW failure, reason: %s" % ret_value["reason"])

    # for automated software management, there is no listOfStepNumbersAndDurations
    return notification, ret_value
