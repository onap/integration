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

import com.github.fge.jsonschema.core.exceptions.ProcessingException;
import org.json.JSONException;
import org.json.JSONObject;
import org.junit.jupiter.api.Test;
import org.onap.pnfsimulator.message.MessageProvider;
import org.onap.pnfsimulator.simulator.validation.JSONValidator;
import org.onap.pnfsimulator.simulator.validation.ValidationException;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

class SimulatorFactoryTest {
    private static final ResourceReader resourceReader = new ResourceReader("org/onap/pnfsimulator/simulator/SimulatorFactoryTest/");

    private static final JSONObject VALID_SIMULATOR_PARAMS = new JSONObject(resourceReader.readResource("validSimulatorParams.json"));
    private static final JSONObject VALID_COMMON_EVENT_HEADER_PARAMS = new JSONObject(resourceReader.readResource("validCommonEventHeaderParams.json"));
    private static final JSONObject VALID_PNF_REGISTRATION_PARAMS = new JSONObject(resourceReader.readResource("validPnfRegistrationParams.json"));
    private static final JSONObject VALID_NOTIFICATION_PARAMS = new JSONObject(resourceReader.readResource("validNotificationParams.json"));

    private static final JSONObject INVALID_SIMULATOR_PARAMS = new JSONObject(resourceReader.readResource("invalidSimulatorParams.json"));
    private static final JSONObject INVALID_PNF_REGISTRATION_PARAMS_1 = new JSONObject(resourceReader.readResource("invalidPnfRegistrationParams1.json"));
    private static final JSONObject INVALID_PNF_REGISTRATION_PARAMS_2 = new JSONObject(resourceReader.readResource("invalidPnfRegistrationParams2.json"));
    private static final JSONObject INVALID_PNF_REGISTRATION_PARAMS_3 = new JSONObject(resourceReader.readResource("invalidPnfRegistrationParams3.json"));

    private SimulatorFactory simulatorFactory = new SimulatorFactory(new MessageProvider(), new JSONValidator());

    @Test
    void should_successfully_create_simulator_given_valid_pnf_registration_params_and_valid_output_message()
            throws ValidationException, IOException, ProcessingException {
        assertNotNull(simulatorFactory.createSimulatorWithPnfRegistration(VALID_SIMULATOR_PARAMS, VALID_COMMON_EVENT_HEADER_PARAMS,
                VALID_PNF_REGISTRATION_PARAMS));
    }

    @Test
    void should_successfully_create_simulator_given_valid_notification_params_and_valid_output_message()
            throws ValidationException, IOException, ProcessingException {
        assertNotNull(simulatorFactory.createSimulatorWithNotification(VALID_SIMULATOR_PARAMS, VALID_COMMON_EVENT_HEADER_PARAMS,
                VALID_NOTIFICATION_PARAMS));
    }

    @Test
    void should_throw_given_invalid_params() {
        assertThrows(
                JSONException.class,
                () -> simulatorFactory.createSimulatorWithPnfRegistration(INVALID_SIMULATOR_PARAMS, VALID_COMMON_EVENT_HEADER_PARAMS,
                        VALID_PNF_REGISTRATION_PARAMS));
    }

    @Test
    void should_throw_given_valid_params_and_invalid_output_message() {

        assertThrows(
                ValidationException.class,
                () -> simulatorFactory.createSimulatorWithPnfRegistration(VALID_SIMULATOR_PARAMS, VALID_COMMON_EVENT_HEADER_PARAMS,
                        INVALID_PNF_REGISTRATION_PARAMS_1));

        assertThrows(
                ValidationException.class,
                () -> simulatorFactory.createSimulatorWithPnfRegistration(VALID_SIMULATOR_PARAMS, VALID_COMMON_EVENT_HEADER_PARAMS,
                        INVALID_PNF_REGISTRATION_PARAMS_2));

        assertThrows(
                ValidationException.class,
                () -> simulatorFactory.createSimulatorWithPnfRegistration(VALID_SIMULATOR_PARAMS, VALID_COMMON_EVENT_HEADER_PARAMS,
                        INVALID_PNF_REGISTRATION_PARAMS_3));
    }
}