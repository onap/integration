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

import com.tailf.jnc.Element;
import com.tailf.jnc.JNCException;
import com.tailf.jnc.NetconfSession;
import com.tailf.jnc.XMLParser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.onap.netconfsimulator.netconfcore.configuration.NetconfConfigurationEditor;
import org.springframework.util.ResourceUtils;
import org.xml.sax.InputSource;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.file.Files;

import static org.mockito.Mockito.verify;
import static org.mockito.MockitoAnnotations.initMocks;

class NetconfConfigurationEditorTest {

    @Mock
    private NetconfSession session;
    @Mock
    private NetconfSessionHelper netconfSessionHelper;

    private NetconfConfigurationEditor editor;

    @BeforeEach
    void setUp() throws IOException, JNCException {
        initMocks(this);
        NetconfConnectionParams params = null;
        Mockito.when(netconfSessionHelper.createNetconfSession(params)).thenReturn(session);
        editor = new NetconfConfigurationEditor(params, netconfSessionHelper);
    }

    @Test
    void testShouldEditConfigSuccessfully() throws IOException, JNCException {
        byte[] bytes =
                Files.readAllBytes(ResourceUtils.getFile("classpath:updatedConfig.xml").toPath());
        Element editConfigXml = new XMLParser().parse(new InputSource(new ByteArrayInputStream(bytes)));

        editor.editConfig(editConfigXml);

        verify(session).editConfig(editConfigXml);
    }
}
