/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2018-2019 NOKIA Intellectual Property. All rights reserved.
 * ================================================================================
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============LICENSE_END=========================================================
 */

package org.onap.pnfsimulator.simulator;

import org.json.JSONObject;

final class TestMessages {
    private static final ResourceReader resourceReader = new ResourceReader("org/onap/pnfsimulator/TestMessages/");

    static final JSONObject VALID_SIMULATOR_PARAMS = new JSONObject(resourceReader.readResource("validSimulatorParams.json"));
    static final JSONObject VALID_COMMON_EVENT_HEADER_PARAMS = new JSONObject(resourceReader.readResource("validCommonEventHeaderParams.json"));
    static final JSONObject VALID_PNF_REGISTRATION_PARAMS = new JSONObject(resourceReader.readResource("validPnfRegistrationParams.json"));
    static final JSONObject VALID_NOTIFICATION_PARAMS = new JSONObject(resourceReader.readResource("validNotificationParams.json"));

    static final JSONObject INVALID_SIMULATOR_PARAMS = new JSONObject(resourceReader.readResource("invalidSimulatorParams.json"));
    static final JSONObject INVALID_PNF_REGISTRATION_PARAMS_1 = new JSONObject(resourceReader.readResource("invalidPnfRegistrationParams1.json"));
    static final JSONObject INVALID_PNF_REGISTRATION_PARAMS_2 = new JSONObject(resourceReader.readResource("invalidPnfRegistrationParams2.json"));
    static final JSONObject INVALID_PNF_REGISTRATION_PARAMS_3 = new JSONObject(resourceReader.readResource("invalidPnfRegistrationParams3.json"));

    private TestMessages() {
    }
}
