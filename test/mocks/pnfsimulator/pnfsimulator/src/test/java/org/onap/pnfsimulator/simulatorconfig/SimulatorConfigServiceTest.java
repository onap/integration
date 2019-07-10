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

package org.onap.pnfsimulator.simulatorconfig;

import org.assertj.core.util.Lists;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;

import static org.assertj.core.api.Java6Assertions.assertThat;
import static org.assertj.core.api.Java6Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.mockito.MockitoAnnotations.initMocks;

class SimulatorConfigServiceTest {

    private static final String SAMPLE_ID = "sampleId";
    private static final String SAMPLE_NEW_VES_URL = "http://localhost:8090/eventListener/v7";
    @Mock
    private SimulatorConfigRepository repository;

    @InjectMocks
    private SimulatorConfigService service;

    @BeforeEach
    void resetMocks() {
        initMocks(this);
    }

    @Test
    void testShouldReturnConfiguration() throws MalformedURLException {
        List<SimulatorConfig> expectedConfig = getExpectedConfig();
        when(repository.findAll()).thenReturn(expectedConfig);

        SimulatorConfig configs = service.getConfiguration();

        assertThat(configs).isNotNull();
    }

    @Test
    void testShouldRaiseExceptionWhenNoConfigurationPresent() {
        when(repository.findAll()).thenReturn(Lists.emptyList());

        assertThatThrownBy(() -> service.getConfiguration())
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("No configuration found in db");
    }

    @Test
    void testShouldUpdateConfigurationWithVesUrl() throws MalformedURLException {
        URL updatedUrl = new URL("http://localhost:8090/listener/v8");
        SimulatorConfig configWithUpdates = new SimulatorConfig("sampleId", updatedUrl);
        List<SimulatorConfig> expectedConfig = getExpectedConfig();

        when(repository.findAll()).thenReturn(expectedConfig);
        when(repository.save(any(SimulatorConfig.class))).thenReturn(configWithUpdates);

        SimulatorConfig updatedConfig = service.updateConfiguration(configWithUpdates);

        assertThat(updatedConfig).isEqualToComparingFieldByField(configWithUpdates);
    }

    @Test
    void testShouldRaiseExceptionWhenNoConfigInDbPresentOnUpdate() throws MalformedURLException {
        when(repository.findAll()).thenReturn(Lists.emptyList());

        SimulatorConfig configWithUpdates = new SimulatorConfig(SAMPLE_ID, new URL(SAMPLE_NEW_VES_URL));

        assertThatThrownBy(() -> service.updateConfiguration(configWithUpdates))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("No configuration found in db");
    }

    private List<SimulatorConfig> getExpectedConfig() throws MalformedURLException {
        URL sampleVesUrl = new URL("http://localhost:8080/eventListener/v7");
        SimulatorConfig config = new SimulatorConfig(SAMPLE_ID, sampleVesUrl);
        return Lists.newArrayList(config);
    }

}
