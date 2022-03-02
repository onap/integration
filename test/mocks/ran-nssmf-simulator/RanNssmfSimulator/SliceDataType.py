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

from schematics.types import BaseType, StringType, IntType, LongType
from schematics.types.compound import ModelType, ListType, DictType
from schematics.models import Model


class PerfReqEmbb(Model):
    """Reference 3GPP TS 28.541 V16.5.0, Section 6.4.1."""
    expDataRateDL = IntType()
    expDataRateUL = IntType()
    areaTrafficCapDL = IntType()
    areaTrafficCapUL = IntType()
    overallUserDensity = IntType()
    activityFactor = IntType()


class PerfReqUrllc(Model):
    """TODO"""
    pass


class PerfReq(Model):
    """Reference 3GPP TS 28.541 V16.5.0."""
    perfReqEmbbList = ListType(ModelType(PerfReqEmbb))
    # perfReqUrllcList = ListType(ModelType(PerfReqUrllc))
    perfReqUrllcList = ListType(DictType(BaseType))


class SliceProfile(Model):
    """Reference 3GPP TS 28.541 V16.5.0, Section 6.3.4."""
    sliceProfileId = StringType(required=True)
    sNSSAIList = ListType(StringType(required=True))
    pLMNIdList = ListType(StringType(required=True))
    perfReq = ModelType(PerfReq, required=True)
    maxNumberofUEs = LongType()
    coverageAreaTAList = ListType(IntType())
    latency = IntType()
    uEMobilityLevel = StringType()
    resourceSharingLevel = StringType()


class AllocateNssi(Model):
    """Reference 3GPP TS 28.531 V16.6.0."""
    attributeListIn = ModelType(SliceProfile)


class DeAllocateNssi(Model):
    """Reference 3GPP TS 28.531 V16.6.0."""
    nSSId = StringType(required=True)

class ActivateNssi(Model):
    """Reference 3GPP TS 28.531 V16.6.0."""
    nsiId = StringType(required=True)
    nssiId = StringType(required=True) 

class DeActivateNssi(Model):
    """Reference 3GPP TS 28.531 V16.6.0."""
    nsiId = StringType(required=True)
    nssiId = StringType(required=True) 
