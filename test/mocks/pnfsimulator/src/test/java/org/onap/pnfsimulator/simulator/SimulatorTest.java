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