#! /usr/bin/python3

#  ============LICENSE_START=======================================================
#  Copyright (C) 2020 Huawei Technologies Co., Ltd. All rights reserved.
#  Contribution (C) 2022 Aarna Networks, Inc. All rights reserved.
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

import json
from flask import Flask, request, Response
from schematics.exceptions import DataError

from .utils import REST_PORT, LOGGING_LEVEL
from .SliceDataType import AllocateNssi, DeAllocateNssi, ActivateNssi, DeActivateNssi
from . import AuthManager
from . import NssManager


app = Flask(__name__)
app.logger.setLevel(LOGGING_LEVEL)


@app.errorhandler(DataError)
def handleRequestException(e):
    app.logger.error(e)
    response = Response()
    response.status_code = 400
    return response


@app.errorhandler(AuthManager.AuthError)
def handleAuthException(e):
    app.logger.error(e)
    response = Response()
    response.status_code = 400
    return response


@app.errorhandler(AuthManager.TokenError)
def handleAuthException(e):
    app.logger.error(e)
    response = Response()
    response.status_code = 401
    return response


@app.errorhandler(NssManager.NssError)
def handleNssException(e):
    app.logger.error(e)
    response = Response()
    response.status_code = 400
    return response


@app.route("/api/rest/securityManagement/v1/oauth/token", methods=['POST'])
def handleAuthToken():
    """
        Used to get Access Token by SO NSSMF adapter.
    """
    app.logger.debug("Receive request:\n%s" % json.dumps(request.json, indent=2))

    AuthManager.AuthRequest(request.json).validate()
    AuthManager.checkAuth(request.json)

    return AuthManager.generateAuthToken(request.json), 201


@app.route("/ObjectManagement/NSS/SliceProfiles", methods=['POST'])
def handleAllocateNssi():
    AuthManager.checkAuthToken(request.headers)

    app.logger.info("Receive AllocateNssi request:\n%s" % json.dumps(request.json, indent=2))

    AllocateNssi(request.json).validate()

    return NssManager.allocateNssi(request.json), 200


@app.route("/ObjectManagement/NSS/SliceProfiles/<string:sliceProfileId>", methods=['DELETE'])
def handleDeallocateNssi(sliceProfileId):
    AuthManager.checkAuthToken(request.headers)

    app.logger.info("Receive DeallocateNssi request for sliceProfileId %s:\n%s"
                    % (sliceProfileId, json.dumps(request.json, indent=2)))

    DeAllocateNssi(request.json).validate()

    return NssManager.deallocateNssi(sliceProfileId, request.json), 200

@app.route("/api/rest/provMns/v1/an/NSS/<string:snssai>/activations", methods=['PUT'])
def handleActivateNssi(snssai):
    AuthManager.checkAuthToken(request.headers)

    app.logger.info("Receive ActivateNssi request for snssai:%s\n%s" % (snssai, json.dumps(request.json, indent=2)))

    ActivateNssi(request.json).validate()

    return NssManager.activateNssi(snssai, request.json), 200

@app.route("/api/rest/provMns/v1/an/NSS/<string:snssai>/deactivation", methods=['PUT'])
def handleDeActivateNssi():
    AuthManager.checkAuthToken(request.headers)

    app.logger.info("Receive DeActivateNssi request for snssai:%s\n%s" % (snssai, json.dumps(request.json, indent=2)))

    DeActivateNssi(request.json).validate()

    return NssManager.deactivateNssi(snssai, request.json), 200

def main():
    AuthManager.startAuthManagerJob()
    app.run("0.0.0.0", REST_PORT, False, ssl_context="adhoc")


if __name__ == '__main__':
    main()
