#  ============LICENSE_START=======================================================
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

REST_PORT = int(os.getenv("RAN_NSSMF_REST_PORT", "8443"))
LOGGING_LEVEL = os.getenv("RAN_NSSMF_LOGGING_LEVEL", "INFO")

TOKEN_EXPIRES_TIME = int(os.getenv("RAN_NSSMF_TOKEN_EXPIRES_TIME", "30"))
TOKEN_CLEAN_TIME = int(os.getenv("RAN_NSSMF_TOKEN_CLEAN_TIME", "180"))

AUTH_DB = os.getenv("RAN_NSSMF_AUTH_DB", "db/auth.json")

LOGGER_FORMAT = "[%(asctime)-15s] %(levelname)s in %(name)s: %(message)s"


def getLogger(name, level=LOGGING_LEVEL, fmt=LOGGER_FORMAT):
    logger = logging.getLogger(name)
    logger.setLevel(level)

    formatter = logging.Formatter(fmt)
    cmd_handler = logging.StreamHandler()
    cmd_handler.setFormatter(formatter)
    logger.addHandler(cmd_handler)

    return logger
