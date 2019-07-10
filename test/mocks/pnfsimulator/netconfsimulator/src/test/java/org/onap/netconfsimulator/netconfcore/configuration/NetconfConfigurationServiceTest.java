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
 *            http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============LICENSE_END=========================================================
 */

package org.onap.netconfsimulator.netconfcore.configuration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.mockito.MockitoAnnotations.initMocks;

import com.tailf.jnc.Element;
import com.tailf.jnc.JNCException;
import java.io.IOException;
import java.nio.file.Files;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.util.ResourceUtils;

class NetconfConfigurationServiceTest {

    @Mock
    NetconfConfigurationReader reader;

    @Mock
    NetconfConfigurationEditor editor;

    @InjectMocks
    NetconfConfigurationService service;

  private static String CURRENT_CONFIG_XML_STRING =
      "<config xmlns=\"http://onap.org/pnf-simulator\" xmlns:nc=\"urn:ietf:params:xml:ns:netconf:base:1.0\">\n"
          + "  <itemValue1>100</itemValue1>\n"
          + "  <itemValue2>200</itemValue2>\n"
          + "</config>\n";

    @BeforeEach
    void setUp() {
        initMocks(this);
    }

    @Test
    void testShouldReturnCorrectCurrentConfiguration() throws IOException, JNCException {
        String expectedConfiguration = CURRENT_CONFIG_XML_STRING;
        when(reader.getRunningConfig()).thenReturn(CURRENT_CONFIG_XML_STRING);

        String actualCurrentConfiguration = service.getCurrentConfiguration();

        assertThat(actualCurrentConfiguration).isEqualToIgnoringCase(expectedConfiguration);
    }

    @Test
    void testShouldThrowExceptionWhenCurrentConfigurationDoesNotExists() throws IOException, JNCException{
        when(reader.getRunningConfig()).thenThrow(JNCException.class);

        assertThatThrownBy(() -> service.getCurrentConfiguration()).isInstanceOf(JNCException.class);
    }

    @Test
    void testShouldEditConfigurationSuccessfully() throws IOException, JNCException{
        byte[] bytes =
                Files.readAllBytes(ResourceUtils.getFile("classpath:updatedConfig.xml").toPath());
        MockMultipartFile editConfigXmlContent = new MockMultipartFile("editConfigXml", bytes);
        ArgumentCaptor<Element> elementCaptor = ArgumentCaptor.forClass(Element.class);
        doNothing().when(editor).editConfig(elementCaptor.capture());

        service.editCurrentConfiguration(editConfigXmlContent);

        assertThat(elementCaptor.getValue().toXMLString()).isEqualTo(CURRENT_CONFIG_XML_STRING);
    }

    @Test
    void testShouldRaiseExceptionWhenMultipartFileIsInvalidXmlFile() throws IOException {
        byte[] bytes =
                Files.readAllBytes(ResourceUtils.getFile("classpath:invalidXmlFile.xml").toPath());
        MockMultipartFile editConfigXmlContent = new MockMultipartFile("editConfigXml", bytes);

        assertThatThrownBy(() -> service.editCurrentConfiguration(editConfigXmlContent)).isInstanceOf(JNCException.class);
    }

}
