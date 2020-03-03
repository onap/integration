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

import sys
import os

SWM_DIR = sys.path[0]

LOGGER_FORMAT = "[%(asctime)-15s] %(levelname)s [%(name)s]: %(message)s"
LOGGER_FILE_DIR = os.path.join(SWM_DIR, "log")

NE_INFO_TABLE = os.path.join(SWM_DIR, "ems_db", "ne_info_table.json")
SW_SERVER_SIMULATOR = os.path.join(SWM_DIR, "sw_server_simulator")
PNF_SIMULATORS_DIR = os.path.join(SWM_DIR, "pnf_simulators")
COMMON_PATH = "opt"
PNF_SW_DOWNLOAD_DIR = "download"
PNF_SW_INSTALL_DIR = "install"
MANIFEST_FILE = "manifest.json"
INSTALLED_SW_FILE = "installed_sw.json"
CURRENT_VERSION_DIR = "current"
NOTIFICATION_DIR = "/tmp"

MAX_INT = (2**32) - 1

OBJECT_CLASS = "NRCellDU"
OBJECT_INSTANCE = "DC=com, SubNetwork=1, ManagedElement=123, GNBDUFunction=1, NRCellDU=1"
SYSTEM_DN = "DC=com, SubNetwork=1, ManagedElement=123"

STATUS_DOWNLOADING = "Downloading"
STATUS_INSTALLING = "Installing"
STATUS_ACTIVATING = "Activating"
STATUS_ACTIVATED = "Activated"

STATUS_PRECHECKED = "PreChecked"
STATUS_POSTCHECKED = "PostChecked"

REQ_SUCCESS = "requestAccepted"
REQ_FAILURE = "requestFailed"

RET_CODE_SUCCESS = 0
RET_CODE_FAILURE = 1

RESULT_SUCCESS = "Success"
RESULT_FAILURE = "Failure"
RESULT_PARTLY = "Partly successful"
