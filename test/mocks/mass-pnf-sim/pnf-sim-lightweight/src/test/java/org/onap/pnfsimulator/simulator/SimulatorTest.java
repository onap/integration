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

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTimeout;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.atLeast;
import static org.mockito.Mockito.verify;

import java.time.Duration;
import org.json.JSONObject;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.function.Executable;
import org.mockito.Mockito;
import org.onap.pnfsimulator.simulator.client.HttpClientAdapter;

class SimulatorTest {

    private static final String TEST_VES_URL = "http://test-ves-url";

    @Test
    void builder_should_create_endless_simulator_when_duration_not_specified() {
        Simulator simulator = Simulator
            .builder()
            .withDuration(Duration.ofSeconds(1))
            .withVesUrl(TEST_VES_URL).build();

        assertFalse(simulator.isEndless());

        simulator = Simulator
            .builder()
            .withVesUrl(TEST_VES_URL).build();

        assertTrue(simulator.isEndless());
    }

    @Test
    void simulator_should_send_given_message() {

        JSONObject messageBody = new JSONObject("{\"key\":\"val\"}");
        HttpClientAdapter httpClientMock = Mockito.mock(HttpClientAdapter.class);

        Simulator simulator = Simulator.builder()
            .withDuration(Duration.ofMillis(100))
            .withInterval(Duration.ofMillis(10))
            .withMessageBody(messageBody)
            .withCustomHttpClientAdapter(httpClientMock)
            .withVesUrl(TEST_VES_URL).build();

        simulator.start();

        assertTimeout(Duration.ofMillis(150), (Executable) simulator::join);
        verify(httpClientMock, atLeast(2)).send(messageBody.toString(), TEST_VES_URL);
    }

    @Test
    void simulator_should_stop_when_interrupted() {

        JSONObject messageBody = new JSONObject("{\"key\":\"val\"}");
        HttpClientAdapter httpClientMock = Mockito.mock(HttpClientAdapter.class);

        Simulator simulator = Simulator.builder()
            .withInterval(Duration.ofSeconds(1))
            .withMessageBody(messageBody)
            .withCustomHttpClientAdapter(httpClientMock)
            .withVesUrl(TEST_VES_URL).build();

        simulator.start();
        simulator.interrupt();

        assertTimeout(Duration.ofSeconds(1), (Executable) simulator::join);
    }
}