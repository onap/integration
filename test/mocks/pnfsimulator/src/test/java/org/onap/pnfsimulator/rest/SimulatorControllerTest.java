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

package org.onap.pnfsimulator.rest;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.onap.pnfsimulator.simulator.ResourceReader;
import org.onap.pnfsimulator.simulator.Simulator;
import org.onap.pnfsimulator.simulator.SimulatorFactory;
import org.onap.pnfsimulator.simulator.client.HttpClientAdapter;
import org.onap.pnfsimulator.simulator.validation.JSONValidator;
import org.onap.pnfsimulator.simulator.validation.ValidationException;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.time.Duration;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class SimulatorControllerTest {

    private static final String START_URL = "/simulator/start";
    private static final String STOP_URL = "/simulator/stop";
    private static final String STATUS_URL = "/simulator/status";
    private static final String JSON_MSG_EXPRESSION = "$.message";
    private static final String JSON_STATUS_EXPRESSION = "$.simulatorStatus";
    private static String pnfRegistrationJson;
    private static String incorrectJson;

    private MockMvc mockMvc;

    @InjectMocks
    private SimulatorController controller;

    @Mock
    private SimulatorFactory factory;

    @Mock
    private JSONValidator validator;

    private Simulator simulator;

    @BeforeAll
    static void beforeAll() {
        ResourceReader reader = new ResourceReader("org/onap/pnfsimulator/rest/SimulatorControllerTest/");
        pnfRegistrationJson = reader.readResource("pnfRegistration.json");
        incorrectJson = reader.readResource("incorrectJson.json");
    }

    @BeforeEach
    void setup() {
        MockitoAnnotations.initMocks(this);
        simulator = createEndlessSimulator();
        mockMvc = MockMvcBuilders
                .standaloneSetup(controller)
                .build();
    }

    private Simulator createEndlessSimulator() {
        return spy(Simulator.builder()
                .withCustomHttpClientAdapter(mock(HttpClientAdapter.class))
                .withInterval(Duration.ofMinutes(1))
                .build());
    }

    @Test
    void wrongJSONFormatOnStart() throws Exception {
        when(factory.createSimulatorWithNotification(any(), any(), any())).thenReturn(simulator);
        doThrow(new ValidationException("")).when(validator).validate(anyString(), anyString());

        mockMvc.perform(post("/simulator/start").content(incorrectJson))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Cannot start simulator - Json format " +
                        "is not compatible with schema definitions"));
        verify(validator).validate(anyString(), anyString());
    }

    @Test
    void startSimulatorProperly() throws Exception {
        startSimulatorWithPnfRegistration();

        verify(validator).validate(anyString(), anyString());
        verify(factory).createSimulatorWithPnfRegistration(any(), any(), any());
        verify(simulator).start();
    }

    @Test
    void notStartWhenAlreadyRunning() throws Exception {
        startSimulatorWithPnfRegistration();

        mockMvc
                .perform(post(START_URL).content(pnfRegistrationJson))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath(JSON_MSG_EXPRESSION).value("Cannot start simulator since it's already running"));
    }

    @Test
    void stopSimulatorWhenRunning() throws Exception {
        startSimulatorWithPnfRegistration();

        mockMvc
                .perform(post(STOP_URL))
                .andExpect(status().isOk())
                .andExpect(jsonPath(JSON_MSG_EXPRESSION).value("Simulator successfully stopped"));
    }

    @Test
    void getNotRunningMessageWhenOff() throws Exception {
        mockMvc
                .perform(post(STOP_URL))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath(JSON_MSG_EXPRESSION).value("Cannot stop simulator, because it's not running"));
    }

    @Test
    void getRunningStatusWhenOn() throws Exception {
        startSimulatorWithPnfRegistration();

        mockMvc
                .perform(get(STATUS_URL))
                .andExpect(status().isOk())
                .andExpect(jsonPath(JSON_STATUS_EXPRESSION).value("RUNNING"));
    }

    @Test
    void getNotRunningStatusWhenOff() throws Exception {
        mockMvc
                .perform(get(STATUS_URL))
                .andExpect(status().isOk())
                .andExpect(jsonPath(JSON_STATUS_EXPRESSION).value("NOT RUNNING"));
    }

    private void startSimulatorWithPnfRegistration() throws Exception {
        when(factory.createSimulatorWithPnfRegistration(any(), any(), any())).thenReturn(simulator);

        mockMvc
                .perform(post(START_URL).content(pnfRegistrationJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath(JSON_MSG_EXPRESSION).value("Simulator started"));
    }
}