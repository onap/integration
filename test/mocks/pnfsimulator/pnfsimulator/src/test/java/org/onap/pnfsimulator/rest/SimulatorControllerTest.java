/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2018 Nokia. All rights reserved.
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

import com.google.common.collect.ImmutableMap;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.onap.pnfsimulator.rest.model.FullEvent;
import org.onap.pnfsimulator.rest.model.SimulatorParams;
import org.onap.pnfsimulator.rest.model.SimulatorRequest;
import org.onap.pnfsimulator.rest.util.JsonObjectDeserializer;
import org.onap.pnfsimulator.simulator.SimulatorService;
import org.onap.pnfsimulator.simulatorconfig.SimulatorConfig;
import org.quartz.SchedulerException;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.result.MockMvcResultHandlers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.io.IOException;
import java.net.URL;
import java.security.GeneralSecurityException;

import static org.assertj.core.api.Java6Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class SimulatorControllerTest {

    private static final String START_ENDPOINT = "/simulator/start";
    private static final String CONFIG_ENDPOINT = "/simulator/config";
    private static final String EVENT_ENDPOINT = "/simulator/event";
    private static final String JSON_MSG_EXPRESSION = "$.message";

    private static final String NEW_URL = "http://0.0.0.0:8090/eventListener/v7";
    private static final String UPDATE_SIM_CONFIG_VALID_JSON = "{\"vesServerUrl\": \"" + NEW_URL + "\"}";
    private static final String SAMPLE_ID = "sampleId";
    private static final Gson GSON_OBJ = new Gson();
    private static String simulatorRequestBody;
    private MockMvc mockMvc;
    @InjectMocks
    private SimulatorController controller;
    @Mock
    private SimulatorService simulatorService;

    @BeforeAll
    static void beforeAll() {
        SimulatorParams simulatorParams = new SimulatorParams("http://0.0.0.0:8080", 1, 1);
        SimulatorRequest simulatorRequest = new SimulatorRequest(simulatorParams,
                "testTemplate.json", new JsonObject());

        simulatorRequestBody = GSON_OBJ.toJson(simulatorRequest);
    }

    @BeforeEach
    void setup() throws IOException, SchedulerException, GeneralSecurityException {
        MockitoAnnotations.initMocks(this);
        when(simulatorService.triggerEvent(any())).thenReturn("jobName");
        mockMvc = MockMvcBuilders
                .standaloneSetup(controller)
                .build();
    }

    @Test
    void shouldStartSimulatorProperly() throws Exception {
        startSimulator();
        SimulatorRequest simulatorRequest = new Gson().fromJson(simulatorRequestBody, SimulatorRequest.class);

        verify(simulatorService).triggerEvent(eq(simulatorRequest));
    }

    @Test
    void testShouldGetConfigurationWhenRequested() throws Exception {
        String newUrl = "http://localhost:8090/eventListener/v7";
        SimulatorConfig expectedConfig = new SimulatorConfig(SAMPLE_ID, new URL(newUrl));
        when(simulatorService.getConfiguration()).thenReturn(expectedConfig);

        MvcResult getResult = mockMvc
                .perform(get(CONFIG_ENDPOINT)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(UPDATE_SIM_CONFIG_VALID_JSON))
                .andExpect(status().isOk())
                .andReturn();

        String expectedVesUrlJsonPart = createStringReprOfJson("vesServerUrl", newUrl);
        assertThat(getResult.getResponse().getContentAsString()).contains(expectedVesUrlJsonPart);
    }

    @Test
    void testShouldSuccessfullyUpdateConfigurationWithNewVesUrl() throws Exception {
        String oldUrl = "http://localhost:8090/eventListener/v7";
        SimulatorConfig expectedConfigBeforeUpdate = new SimulatorConfig(SAMPLE_ID, new URL(oldUrl));
        SimulatorConfig expectedConfigAfterUpdate = new SimulatorConfig(SAMPLE_ID, new URL(NEW_URL));

        when(simulatorService.getConfiguration()).thenReturn(expectedConfigBeforeUpdate);
        when(simulatorService.updateConfiguration(any(SimulatorConfig.class))).thenReturn(expectedConfigAfterUpdate);

        MvcResult postResult = mockMvc
                .perform(put(CONFIG_ENDPOINT)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(UPDATE_SIM_CONFIG_VALID_JSON))
                .andExpect(status().isOk())
                .andReturn();

        String expectedVesUrlJsonPart = createStringReprOfJson("vesServerUrl", expectedConfigAfterUpdate.getVesServerUrl().toString());
        assertThat(postResult.getResponse().getContentAsString()).contains(expectedVesUrlJsonPart);
    }

    @Test
    void testShouldRaiseExceptionWhenUpdateConfigWithIncorrectPayloadWasSent() throws Exception {
        mockMvc
                .perform(put(CONFIG_ENDPOINT)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"vesUrl\": \"" + NEW_URL + "\"}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testShouldRaiseExceptionWhenUrlInInvalidFormatIsSent() throws Exception {
        mockMvc
                .perform(put(CONFIG_ENDPOINT)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"vesUrl\": \"http://0.0.0.0:VES-PORT/eventListener/v7\"}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testShouldSendEventDirectly() throws Exception {
        String contentAsString = mockMvc
                .perform(post(EVENT_ENDPOINT)
                        .contentType(MediaType.APPLICATION_JSON_UTF8_VALUE)
                        .content("{\"vesServerUrl\":\"http://0.0.0.0:8080/simulator/v7\",\n" +
                                "      \"event\":{  \n" +
                                "         \"commonEventHeader\":{  \n" +
                                "            \"domain\":\"notification\",\n" +
                                "            \"eventName\":\"vFirewallBroadcastPackets\"\n" +
                                "         },\n" +
                                "         \"notificationFields\":{  \n" +
                                "            \"arrayOfNamedHashMap\":[  \n" +
                                "               {  \n" +
                                "                  \"name\":\"A20161221.1031-1041.bin.gz\",\n" +
                                "                  \"hashMap\":{  \n" +
                                "                     \"fileformatType\":\"org.3GPP.32.435#measCollec\"}}]}}}"))
                .andExpect(status().isAccepted()).andReturn().getResponse().getContentAsString();
        assertThat(contentAsString).contains("One-time direct event sent successfully");
    }

    @Test
    void testShouldReplaceKeywordsAndSendEventDirectly() throws Exception {
        String contentAsString = mockMvc
                .perform(post(EVENT_ENDPOINT)
                        .contentType(MediaType.APPLICATION_JSON_UTF8_VALUE)
                        .content("{\"vesServerUrl\": \"http://localhost:9999/eventListener\",\n" +
                                "    \"event\": {\n" +
                                "        \"commonEventHeader\": {\n" +
                                "            \"eventId\": \"#RandomString(20)\",\n" +
                                "            \"sourceName\": \"PATCHED_sourceName\",\n" +
                                "            \"version\": 3.0\n}}}"))
                .andExpect(status().isAccepted()).andReturn().getResponse().getContentAsString();
        assertThat(contentAsString).contains("One-time direct event sent successfully");

        verify(simulatorService, Mockito.times(1)).triggerOneTimeEvent(any(FullEvent.class));
    }


    private void startSimulator() throws Exception {
        mockMvc
                .perform(post(START_ENDPOINT)
                        .content(simulatorRequestBody)
                        .contentType(MediaType.APPLICATION_JSON).characterEncoding("utf-8"))
                .andExpect(status().isOk())
                .andExpect(jsonPath(JSON_MSG_EXPRESSION).value("Request started"));

    }

    private String createStringReprOfJson(String key, String value) {
        return GSON_OBJ.toJson(ImmutableMap.of(key, value));
    }
}
