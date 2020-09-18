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

"""
    Used to get and check Access Token by SO NSSMF adapter.
"""

import json
import uuid
import time
import sched
import threading
from schematics.types import StringType
from schematics.models import Model

from utils import getLogger, AUTH_DB_FILE, TOKEN_EXPIRES_TIME, TOKEN_CLEAN_TIME


logger = getLogger("AuthManager")
lock = threading.Lock()


class TokenRequest(Model):
    grantType = StringType(required=True)
    userName = StringType(required=True)
    value = StringType(required=True)


class AuthError(ValueError):
    pass


class AuthInfo(object):
    def __init__(self, authRequest, expires):
        self.authRequest = authRequest
        self.expiredTime = int(time.time()) + expires * 60


_AUTH_TOKEN = {}


def cleanExpiredToken():
    s = sched.scheduler(time.time, time.sleep)

    def doCleanExpiredToken():
        current_time = int(time.time())

        expiredTokens = []
        for authToken in _AUTH_TOKEN:
            if current_time > _AUTH_TOKEN[authToken].expiredTime:
                expiredTokens.append(authToken)
                logger.debug("Auth token %s is expired and will be deleted" % authToken)

        with lock:
            for authToken in expiredTokens:
                del _AUTH_TOKEN[authToken]

        s.enter(TOKEN_CLEAN_TIME, 1, doCleanExpiredToken)

    s.enter(TOKEN_CLEAN_TIME, 1, doCleanExpiredToken)

    s.run()


def checkAuth(authRequest):
    with open(AUTH_DB_FILE) as f:
        authDB = json.load(f)

    if authRequest["grantType"].lower() != "password":
        raise AuthError("Unsupported grantType %s" % authRequest["grantType"])

    for authItem in authDB:
        if authItem["userName"].lower() == authRequest["userName"].lower() \
                and authItem["value"] == authRequest["value"]:
            break
    else:
        raise AuthError("userName or password is error")


def generateAuthToken(authRequest):
    token = uuid.uuid4().hex
    with lock:
        _AUTH_TOKEN[token] = AuthInfo(authRequest, TOKEN_EXPIRES_TIME)

    return {
        "accessToken": token,
        "expires": TOKEN_EXPIRES_TIME
    }


def checkAuthToken(requestHeaders):
    authToken = requestHeaders.get("X-Auth-Token")
    logger.debug("X-Auth-Token: %s" % authToken)

    if not authToken:
        raise AuthError("Auth token is missing")

    if authToken not in _AUTH_TOKEN:
        raise AuthError("Auth token is error")

    current_time = int(time.time())
    if current_time > _AUTH_TOKEN[authToken].expiredTime:
        raise AuthError("Auth token is expired")


def startAuthManagerJob():
    cleanThread = threading.Thread(target=cleanExpiredToken)
    cleanThread.daemon = True

    cleanThread.start()

