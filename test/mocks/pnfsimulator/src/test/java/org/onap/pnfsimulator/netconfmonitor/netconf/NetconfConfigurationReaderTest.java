package org.onap.pnfsimulator.netconfmonitor.netconf;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.anyString;
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
import org.mockito.MockitoAnnotations;

class NetconfConfigurationReaderTest {

    private static final String NETCONF_MODEL_PATH = "";
    private static final String EXPECTED_STRING_XML = "<?xml version=\"1.0\"?>";
    private NetconfConfigurationReader reader;

    @Mock
    private NetconfSession netconfSession;
    @Mock
    private NodeSet nodeSet;
    @Mock
    private Element element;

    @BeforeEach
    void setup() {
        MockitoAnnotations.initMocks(this);
        reader = new NetconfConfigurationReader(netconfSession, NETCONF_MODEL_PATH);
    }

    @Test
    void properlyReadXML() throws IOException, JNCException {
        when(netconfSession.getConfig(anyString())).thenReturn(nodeSet);
        when(nodeSet.first()).thenReturn(element);
        when(element.toXMLString()).thenReturn(EXPECTED_STRING_XML);

        String result = reader.read();

        verify(netconfSession).getConfig(anyString());
        verify(nodeSet).first();
        verify(element).toXMLString();
        assertEquals(EXPECTED_STRING_XML, result);
    }
}