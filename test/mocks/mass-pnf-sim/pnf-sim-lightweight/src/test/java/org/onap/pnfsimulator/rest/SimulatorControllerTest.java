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

package org.onap.pnfsimulator.rest;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.onap.pnfsimulator.simulator.TestMessages.VALID_COMMON_EVENT_HEADER_PARAMS;
import static org.onap.pnfsimulator.simulator.TestMessages.VALID_NOTIFICATION_PARAMS;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.onap.pnfsimulator.FileProvider;
import org.onap.pnfsimulator.simulator.Simulator;
import org.onap.pnfsimulator.simulator.SimulatorFactory;
import org.onap.pnfsimulator.simulator.client.HttpClientAdapter;
import org.onap.pnfsimulator.simulator.validation.JSONValidator;
import org.onap.pnfsimulator.simulator.validation.NoRopFilesException;
import org.onap.pnfsimulator.simulator.validation.ValidationException;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

class SimulatorControllerTest {

    private static final String START_URL = "/simulator/start";
    private static final String STOP_URL = "/simulator/stop";
    private static final String STATUS_URL = "/simulator/status";
    private static final String JSON_MSG_EXPRESSION = "$.message";
    private static final String JSON_STATUS_EXPRESSION = "$.simulatorStatus";
    private static final String TEST_VES_URL = "http://localhost:10000/eventListener/v7";
    private static final String TEST_XNF_URL = "sftp://onap:pano@10.11.0.68" + "/";
    private static final String PROPER_JSON = "{\n" +
        "  \"simulatorParams\": {\n" +
        "    \"testDuration\": \"10\",\n" +
        "    \"messageInterval\": \"1\"\n" +
        "  },\n" +
        "  \"commonEventHeaderParams\": {\n" +
        "    \"eventName\": \"val11\",\n" +
        "    \"nfNamingCode\": \"val12\",\n" +
        "    \"nfcNamingCode\": \"val13\",\n" +
        "    \"sourceName\": \"val14\",\n" +
        "    \"sourceId\": \"val15\",\n" +
        "    \"reportingEntityName\": \"val16\",\n" +
        "  },\n" +

        "  \"pnfRegistrationParams\": {\n" +
        "    \"SerialNumber\": \"val1\",\n" +
        "    \"VendorName\": \"val2\",\n" +
        "    \"OamIpv4Address\": \"val3\",\n" +
        "    \"OamIpv6Address\": \"val4\",\n" +
        "    \"Family\": \"val5\",\n" +
        "    \"ModelNumber\": \"val6\",\n" +
        "    \"SoftwareVersion\": \"val7\",\n" +
        "  }\n" +
        "}";
    private static final String WRONG_JSON = "{\n" +
        "  \"mes\": {\n" +
        "    \"vesServerUrl\": \"http://10.154.187.70:8080/eventListener/v5\",\n" +
        "    \"testDuration\": \"10\",\n" +
        "    \"messageInterval\": \"1\"\n" +
        "  },\n" +
        "  \"messageParams\": {\n" +
        "    \"sourceName\": \"val12\",\n" +
        "    \"sourceId\": \"val13\",\n" +
        "    \"reportingEntityName\": \"val14\"\n" +
        "  }\n" +
        "}\n";

    private MockMvc mockMvc;

    @InjectMocks
    private SimulatorController controller;

    @Mock
    private SimulatorFactory factory;
    @Mock
    private JSONValidator validator;

    private Simulator simulator;

    private FileProvider fileProvider = mock(FileProvider.class);

    private void createSampleFileList() {
        List<String> fileList = new ArrayList<>();
        fileList.add("A20190401.1608+0000-1622+0000_excl-eeiwbue-perf-large-pnf-sim-lw-1.xml.gz");
        fileList.add("A20190401.1623+0000-1637+0000_excl-eeiwbue-perf-large-pnf-sim-lw-1.xml.gz");

        try {
            doReturn(fileList).when(fileProvider).getFiles();
        } catch (NoRopFilesException e) {
            e.printStackTrace();
        }
    }

    @BeforeEach
    void setup() {
        MockitoAnnotations.initMocks(this);
        createSampleFileList();
        simulator = createEndlessSimulator();
        mockMvc = MockMvcBuilders
            .standaloneSetup(controller)
            .build();
    }

    private Simulator createEndlessSimulator() {
        return spy(Simulator.builder()
            .withCustomHttpClientAdapter(mock(HttpClientAdapter.class))
            .withCommonEventHeaderParams(VALID_COMMON_EVENT_HEADER_PARAMS)
            .withPnfRegistrationParams(Optional.empty())
            .withNotificationParams(VALID_NOTIFICATION_PARAMS)
            .withVesUrl(TEST_VES_URL)
            .withXnfUrl(TEST_XNF_URL)
            .withFileProvider(fileProvider)
            .withInterval(Duration.ofMinutes(1))
            .build());
    }

    @Test
    void wrongJSONFormatOnStart() throws Exception {
        when(factory.create(any(),any(), any(),any())).thenReturn(simulator);
        doThrow(new ValidationException("")).when(validator).validate(anyString(), anyString());

        mockMvc.perform(post("/simulator/start").content(WRONG_JSON))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.message").value("Cannot start simulator - Json format " +
                "is not compatible with schema definitions"));
        verify(validator).validate(anyString(), anyString());
    }

    @Test
    void startSimulatorProperly() throws Exception {
        startSimulator();

        verify(validator).validate(anyString(), anyString());
        verify(factory).create(any(),any(), any(),any());
        verify(simulator).start();
    }

    @Test
    void notStartWhenAlreadyRunning() throws Exception {
        startSimulator();

        mockMvc
            .perform(post(START_URL).content(PROPER_JSON))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath(JSON_MSG_EXPRESSION).value("Cannot start simulator since it's already running"));
    }

    @Test
    void stopSimulatorWhenRunning() throws Exception {
        startSimulator();

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
        startSimulator();

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

    private void startSimulator() throws Exception {
        when(factory.create(any(), any(), any(),any())).thenReturn(simulator);

        mockMvc
            .perform(post(START_URL).content(PROPER_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath(JSON_MSG_EXPRESSION).value("Simulator started"));
    }
}