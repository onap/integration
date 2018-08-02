package org.onap.pnfsimulator.rest;

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

import java.time.Duration;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.onap.pnfsimulator.simulator.Simulator;
import org.onap.pnfsimulator.simulator.SimulatorFactory;
import org.onap.pnfsimulator.simulator.client.HttpClientAdapter;
import org.onap.pnfsimulator.simulator.validation.JSONValidator;
import org.onap.pnfsimulator.simulator.validation.ValidationException;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

class SimulatorControllerTest {

    private static final String START_URL = "/simulator/start";
    private static final String STOP_URL = "/simulator/stop";
    private static final String STATUS_URL = "/simulator/status";
    private static final String JSON_MSG_EXPRESSION = "$.message";
    private static final String JSON_STATUS_EXPRESSION = "$.simulatorStatus";
    private static final String PROPER_JSON = "{\n" +
        "  \"simulatorParams\": {\n" +
        "    \"vesServerUrl\": \"http://10.154.187.70:8080/eventListener/v5\",\n" +
        "    \"testDuration\": \"10\",\n" +
        "    \"messageInterval\": \"1\"\n" +
        "  },\n" +
        "  \"messageParams\": {\n" +
        "    \"pnfSerialNumber\": \"val1\",\n" +
        "    \"pnfVendorName\": \"val2\",\n" +
        "    \"pnfOamIpv4Address\": \"val3\",\n" +
        "    \"pnfOamIpv6Address\": \"val4\",\n" +
        "    \"pnfFamily\": \"val5\",\n" +
        "    \"pnfModelNumber\": \"val6\",\n" +
        "    \"pnfSoftwareVersion\": \"val7\",\n" +
        "    \"pnfType\": \"val8\",\n" +
        "    \"eventName\": \"val9\",\n" +
        "    \"nfNamingCode\": \"val10\",\n" +
        "    \"nfcNamingCode\": \"val11\",\n" +
        "    \"sourceName\": \"val12\",\n" +
        "    \"sourceId\": \"val13\",\n" +
        "    \"reportingEntityName\": \"val14\"\n" +
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
        when(factory.create(any(), any())).thenReturn(simulator);
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
        verify(factory).create(any(), any());
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
        when(factory.create(any(), any())).thenReturn(simulator);

        mockMvc
            .perform(post(START_URL).content(PROPER_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath(JSON_MSG_EXPRESSION).value("Simulator started"));
    }
}