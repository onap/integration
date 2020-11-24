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

import static org.junit.Assert.assertNull;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTimeout;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.onap.pnfsimulator.simulator.TestMessages.INVALID_NOTIFICATION_PARAMS;
import static org.onap.pnfsimulator.simulator.TestMessages.INVALID_PNF_REGISTRATION_PARAMS_1;
import static org.onap.pnfsimulator.simulator.TestMessages.INVALID_PNF_REGISTRATION_PARAMS_2;
import static org.onap.pnfsimulator.simulator.TestMessages.INVALID_PNF_REGISTRATION_PARAMS_3;
import static org.onap.pnfsimulator.simulator.TestMessages.VALID_COMMON_EVENT_HEADER_PARAMS;
import static org.onap.pnfsimulator.simulator.TestMessages.VALID_NOTIFICATION_PARAMS;
import static org.onap.pnfsimulator.simulator.TestMessages.VALID_PNF_REGISTRATION_PARAMS;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.function.Executable;
import org.mockito.Mockito;
import org.onap.pnfsimulator.FileProvider;
import org.onap.pnfsimulator.simulator.client.HttpClientAdapter;
import org.onap.pnfsimulator.simulator.validation.NoRopFilesException;
import org.onap.pnfsimulator.simulator.validation.ValidationException;

public class SimulatorTest {

    private static final String TEST_VES_URL = "http://localhost:10000/eventListener/v7";
    private static final String TEST_XNF_URL = "sftp://onap:pano@10.11.0.68" + "/";
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
    void simulator_should_stop_when_interrupted() {
        createSampleFileList();

        HttpClientAdapter httpClientMock = Mockito.mock(HttpClientAdapter.class);
        Simulator simulator = Simulator.builder()
            .withInterval(Duration.ofSeconds(1))
            .withCustomHttpClientAdapter(httpClientMock)
            .withCommonEventHeaderParams(VALID_COMMON_EVENT_HEADER_PARAMS)
            .withPnfRegistrationParams(Optional.empty())
            .withNotificationParams(VALID_NOTIFICATION_PARAMS)
            .withVesUrl(TEST_VES_URL)
            .withXnfUrl(TEST_XNF_URL)
            .withCustomHttpClientAdapter(httpClientMock)
            .withFileProvider(fileProvider).build();

        simulator.start();
        simulator.interrupt();

        assertTimeout(Duration.ofSeconds(1), (Executable) simulator::join);
    }

    @Test
    void should_throw_noropfiles_exception_given_empty_filelist() {
        Simulator simulator = Simulator.builder()
                .withDuration(Duration.ofMillis(100))
                .withInterval(Duration.ofMillis(100))
                .withCommonEventHeaderParams(VALID_COMMON_EVENT_HEADER_PARAMS)
                .withPnfRegistrationParams(VALID_PNF_REGISTRATION_PARAMS)
                .withNotificationParams(Optional.empty())
                .withVesUrl(TEST_VES_URL)
                .withXnfUrl(TEST_XNF_URL)
                .withFileProvider(new FileProvider()).build();
        simulator.run();
        Exception e = simulator.getThrownException();
        assertTrue(e instanceof NoRopFilesException);
    }

    @Test
    void should_throw_validation_exception_given_invalid_params() {
        createSampleFileList();

        Simulator simulator = Simulator.builder()
                .withDuration(Duration.ofMillis(100))
                .withInterval(Duration.ofMillis(100))
                .withCommonEventHeaderParams(VALID_COMMON_EVENT_HEADER_PARAMS)
                .withPnfRegistrationParams(INVALID_PNF_REGISTRATION_PARAMS_1)
                .withNotificationParams(Optional.empty())
                .withVesUrl(TEST_VES_URL)
                .withXnfUrl(TEST_XNF_URL)
                .withFileProvider(fileProvider).build();
        simulator.run();
        Exception e = simulator.getThrownException();
        assertTrue(e instanceof ValidationException);

        simulator = Simulator.builder()
                .withDuration(Duration.ofMillis(100))
                .withInterval(Duration.ofMillis(100))
                .withCommonEventHeaderParams(VALID_COMMON_EVENT_HEADER_PARAMS)
                .withPnfRegistrationParams(INVALID_PNF_REGISTRATION_PARAMS_2)
                .withNotificationParams(Optional.empty())
                .withVesUrl(TEST_VES_URL)
                .withXnfUrl(TEST_XNF_URL)
                .withFileProvider(fileProvider).build();
        simulator.run();
        e = simulator.getThrownException();
        assertTrue(e instanceof ValidationException);

        simulator = Simulator.builder()
                .withDuration(Duration.ofMillis(100))
                .withInterval(Duration.ofMillis(100))
                .withCommonEventHeaderParams(VALID_COMMON_EVENT_HEADER_PARAMS)
                .withPnfRegistrationParams(INVALID_PNF_REGISTRATION_PARAMS_3)
                .withNotificationParams(Optional.empty())
                .withVesUrl(TEST_VES_URL)
                .withXnfUrl(TEST_XNF_URL)
                .withFileProvider(fileProvider).build();
        simulator.run();
        e = simulator.getThrownException();
        assertTrue(e instanceof ValidationException);

        simulator = Simulator.builder()
                .withDuration(Duration.ofMillis(100))
                .withInterval(Duration.ofMillis(100))
                .withCommonEventHeaderParams(VALID_COMMON_EVENT_HEADER_PARAMS)
                .withPnfRegistrationParams(VALID_PNF_REGISTRATION_PARAMS)
                .withNotificationParams(INVALID_NOTIFICATION_PARAMS)
                .withVesUrl(TEST_VES_URL)
                .withXnfUrl(TEST_XNF_URL)
                .withFileProvider(fileProvider).build();
        simulator.run();
        e = simulator.getThrownException();
        assertTrue(e instanceof ValidationException);
    }

    @Test
    void simulator_should_send_fileready_message() {
        createSampleFileList();

        HttpClientAdapter httpClientMock = Mockito.mock(HttpClientAdapter.class);
        Simulator simulator = Simulator.builder()
                .withDuration(Duration.ofMillis(100))
                .withInterval(Duration.ofMillis(100))
                .withCommonEventHeaderParams(VALID_COMMON_EVENT_HEADER_PARAMS)
                .withPnfRegistrationParams(Optional.empty())
                .withNotificationParams(VALID_NOTIFICATION_PARAMS)
                .withVesUrl(TEST_VES_URL)
                .withXnfUrl(TEST_XNF_URL)
                .withCustomHttpClientAdapter(httpClientMock)
                .withFileProvider(fileProvider).build();
        simulator.run();
        Exception e = simulator.getThrownException();
        assertNull(e);

        assertTimeout(Duration.ofMillis(150), (Executable) simulator::join);
        verify(httpClientMock, times(1)).send(anyString(), eq(TEST_VES_URL));
    }
}

