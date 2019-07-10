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

package org.onap.netconfsimulator.netconfcore.configuration;

import static org.assertj.core.api.AssertionsForInterfaceTypes.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.tailf.jnc.Element;
import com.tailf.jnc.JNCException;
import com.tailf.jnc.NetconfSession;
import com.tailf.jnc.NodeSet;
import java.io.IOException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;

class NetconfConfigurationReaderTest {

    private static final String NETCONF_MODEL_PATH = "";
    private static final String EXPECTED_STRING_XML = "<?xml version=\"1.0\"?>";
    private NetconfConfigurationReader reader;

    @Mock
    private NetconfSession netconfSession;

    @Mock
    private NetconfSessionHelper netconfSessionHelper;

    @Mock
    private NodeSet nodeSet;

    @Mock
    private Element element;

    @BeforeEach
    void setUp() throws IOException, JNCException {
        MockitoAnnotations.initMocks(this);
        NetconfConnectionParams params = null;
        Mockito.when(netconfSessionHelper.createNetconfSession(params)).thenReturn(netconfSession);
        reader = new NetconfConfigurationReader(params, netconfSessionHelper);
    }

    @Test
    void properlyReadXML() throws IOException, JNCException {
        when(netconfSession.getConfig()).thenReturn(nodeSet);
        when(nodeSet.toXMLString()).thenReturn(EXPECTED_STRING_XML);

        String result = reader.getRunningConfig();

        verify(netconfSession).getConfig();
        verify(nodeSet).toXMLString();
        assertThat(result).isEqualTo(EXPECTED_STRING_XML);
    }

    @Test
    void shouldProperlyReadXmlByName() throws IOException, JNCException {
        when(netconfSession.getConfig("/sample:test")).thenReturn(nodeSet);
        when(nodeSet.first()).thenReturn(element);
        when(element.toXMLString()).thenReturn(EXPECTED_STRING_XML);

        String result = reader.getRunningConfig("/sample:test");

        verify(netconfSession).getConfig("/sample:test");
        verify(nodeSet, times(2)).first();
        verify(element).toXMLString();

        assertThat(result).isEqualTo(EXPECTED_STRING_XML);
    }

}
