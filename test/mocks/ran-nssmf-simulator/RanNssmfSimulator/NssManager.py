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

import uuid

from .utils import getLogger


logger = getLogger("NssManager")


class NssError(ValueError):
    pass


def allocateNssi(requestBody):
    sliceProfile = requestBody["attributeListIn"]
    sliceProfileId = sliceProfile["sliceProfileId"]

    nSSId = uuid.uuid4().hex

    responseBody = {
        "attributeListOut": {},
        "href": nSSId
    }

    logger.info("Allocate NSSI for sliceProfileId %s success, nSSId: %s" % (sliceProfileId, nSSId))
    return responseBody


def deallocateNssi(sliceProfileId, requestBody):
    nSSId = requestBody["nSSId"]

    logger.info("Deallocate NSSI for sliceProfileId %s success, nSSId: %s" % (sliceProfileId, nSSId))
    return ""
