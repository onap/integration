package org.onap.pnfsimulator.netconfmonitor;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;

import com.tailf.jnc.JNCException;
import com.tailf.jnc.NetconfSession;
import java.io.IOException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;

class NetconfMonitorServiceConfigurationTest {

    private NetconfMonitorServiceConfiguration configuration;

    @Mock
    private NetconfSession netconfSession;

    @BeforeEach
    void setup() {
        netconfSession = mock(NetconfSession.class);
        configuration = spy(new NetconfMonitorServiceConfiguration());
    }

    @Test
    void readNetconfConfiguration() throws IOException, JNCException {
        doReturn(netconfSession).when(configuration).createNetconfSession(any());

        assertNotNull(configuration.configurationReader());
        verify(configuration).createNetconfSession(any());
    }

    @Test
    void configurationCacheIsNotNull() {
        assertNotNull(configuration.configurationCache());
    }

    @Test
    void netconfConfigurationWriterIsNotNull() {
        assertNotNull(configuration.netconfConfigurationWriter());
    }

    @Test
    void timerIsNotNull() {
        assertNotNull(configuration.timer());
    }
}