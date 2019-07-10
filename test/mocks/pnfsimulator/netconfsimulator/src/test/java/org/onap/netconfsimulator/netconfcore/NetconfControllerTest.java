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
 *                        http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============LICENSE_END=========================================================
 */

package org.onap.netconfsimulator.netconfcore;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.MockitoAnnotations.initMocks;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.tailf.jnc.JNCException;
import java.io.IOException;
import java.nio.file.Files;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.onap.netconfsimulator.netconfcore.configuration.NetconfConfigurationService;
import org.onap.netconfsimulator.netconfcore.model.LoadModelResponse;
import org.onap.netconfsimulator.netconfcore.model.NetconfModelLoaderService;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.util.ResourceUtils;
import org.springframework.web.multipart.MultipartFile;

class NetconfControllerTest {

    private MockMvc mockMvc;

    @Mock
    private NetconfConfigurationService netconfService;

    @Mock
    private NetconfModelLoaderService netconfModelLoaderService;

    @InjectMocks
    private NetconfController controller;

    private static final String SAMPLE_CONFIGURATION = "<config xmlns=\"http://onap.org/pnf-simulator\" xmlns:nc=\"urn:ietf:params:xml:ns:netconf:base:1.0\"><itemValue1>11</itemValue1><itemValue2>22</itemValue2></config>";

    @BeforeEach
    void setUp() {
        initMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(controller).build();
    }

    @Test
    void testShouldDigestMultipartFile() throws Exception {
        byte[] bytes =
            Files.readAllBytes(ResourceUtils.getFile("classpath:updatedConfig.xml").toPath());
        MockMultipartFile file = new MockMultipartFile("editConfigXml", bytes);

        mockMvc
            .perform(MockMvcRequestBuilders.multipart("/netconf/edit-config").file(file))
            .andExpect(status().isAccepted());

        verify(netconfService).editCurrentConfiguration(any(MultipartFile.class));
    }

    @Test
    void testShouldThrowExceptionWhenEditConfigFileWithIncorrectNameProvided() throws Exception {
        MockMultipartFile file = new MockMultipartFile("wrongName", new byte[0]);

        mockMvc
            .perform(MockMvcRequestBuilders.multipart("/netconf/edit-config").file(file))
            .andExpect(status().isBadRequest());

        verify(netconfService, never()).editCurrentConfiguration(any(MultipartFile.class));
    }

    @Test
    void testShouldReturnCurrentConfiguration() throws Exception {
        when(netconfService.getCurrentConfiguration()).thenReturn(SAMPLE_CONFIGURATION);

        String contentAsString =
            mockMvc
                .perform(get("/netconf/get"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        verify(netconfService).getCurrentConfiguration();
        assertThat(contentAsString).isEqualTo(SAMPLE_CONFIGURATION);
    }

    @Test
    void testShouldReturnConfigurationForGivenPath() throws Exception {
        when(netconfService.getCurrentConfiguration("sampleModel", "sampleContainer"))
            .thenReturn(SAMPLE_CONFIGURATION);

        String contentAsString =
            mockMvc
                .perform(get("/netconf/get/sampleModel/sampleContainer"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        verify(netconfService).getCurrentConfiguration("sampleModel", "sampleContainer");
        assertThat(contentAsString).isEqualTo(SAMPLE_CONFIGURATION);
    }

    @Test
    void testShouldRaiseBadRequestWhenConfigurationIsNotPresent() throws Exception {
        when(netconfService.getCurrentConfiguration("sampleModel", "sampleContainer2"))
            .thenThrow(new JNCException(JNCException.ELEMENT_MISSING, "/sampleModel:sampleContainer2"));

        String contentAsString =
            mockMvc
            .perform(get("/netconf/get/sampleModel/sampleContainer2"))
            .andExpect(status().isBadRequest())
            .andReturn()
            .getResponse()
            .getContentAsString();

        assertThat(contentAsString).isEqualTo("Element does not exists: /sampleModel:sampleContainer2");
    }

    @Test
    void shouldThrowExceptionWhenNoConfigurationPresent() throws IOException, JNCException {
        when(netconfService.getCurrentConfiguration()).thenThrow(JNCException.class);

        assertThatThrownBy(() -> mockMvc.perform(get("/netconf/get")))
            .hasRootCauseExactlyInstanceOf(JNCException.class);
    }

    @Test
    void testShouldDeleteYangModel() throws Exception {
        String responseOkString = "Alles klar";
        String yangModelName = "someModel";
        LoadModelResponse loadModelResponse = new LoadModelResponse(200, responseOkString);
        String uri = String.format("/netconf/model/%s", yangModelName);
        when(netconfModelLoaderService.deleteYangModel(yangModelName)).thenReturn(loadModelResponse);

        String contentAsString =
            mockMvc
                .perform(delete(uri))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        verify(netconfModelLoaderService).deleteYangModel(yangModelName);
        assertThat(contentAsString).isEqualTo(responseOkString);
    }
}
