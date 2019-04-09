/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2018 NOKIA Intellectual Property. All rights reserved.
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

import static org.junit.Assert.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.onap.pnfsimulator.simulator.TestMessages.INVALID_SIMULATOR_PARAMS;
import static org.onap.pnfsimulator.simulator.TestMessages.VALID_COMMON_EVENT_HEADER_PARAMS;
import static org.onap.pnfsimulator.simulator.TestMessages.VALID_NOTIFICATION_PARAMS;
import static org.onap.pnfsimulator.simulator.TestMessages.VALID_PNF_REGISTRATION_PARAMS;
import static org.onap.pnfsimulator.simulator.TestMessages.VALID_SIMULATOR_PARAMS;
import java.util.Optional;
import org.json.JSONException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class SimulatorFactoryTest {


    private SimulatorFactory simulatorFactory;

    @BeforeEach
    void setUp() {
        simulatorFactory = new SimulatorFactory();
    }

    @Test
    void should_successfully_create_simulator_given_valid_pnf_registration_params() {
        assertNotNull(simulatorFactory.create(VALID_SIMULATOR_PARAMS, VALID_COMMON_EVENT_HEADER_PARAMS,
            VALID_PNF_REGISTRATION_PARAMS, Optional.empty()));
    }

    @Test
    void should_successfully_create_simulator_given_valid_notification_params_and_valid_output_message() {
        assertNotNull(simulatorFactory.create(VALID_SIMULATOR_PARAMS, VALID_COMMON_EVENT_HEADER_PARAMS,
            Optional.empty(), VALID_NOTIFICATION_PARAMS));
    }

    @Test
    void should_throw_given_invalid_simulator_params() {
        assertThrows(
            JSONException.class,
            () -> simulatorFactory.create(INVALID_SIMULATOR_PARAMS, VALID_COMMON_EVENT_HEADER_PARAMS,
                VALID_PNF_REGISTRATION_PARAMS, VALID_NOTIFICATION_PARAMS));
    }
}


