package org.onap.pnfsimulator.netconfmonitor;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.anyLong;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.tailf.jnc.JNCException;
import java.io.IOException;
import java.util.Timer;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationCache;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationReader;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationWriter;

class NetconfMonitorServiceTest {

    private NetconfMonitorService service;

    @Mock
    private Timer timer;
    @Mock
    private NetconfConfigurationReader reader;
    @Mock
    private NetconfConfigurationWriter writer;
    @Mock
    private NetconfConfigurationCache cache;

    @BeforeEach
    void setup() {
        MockitoAnnotations.initMocks(this);
        service = new NetconfMonitorService(timer, reader, writer, cache);
    }

    @Test
    void startNetconfService() throws IOException, JNCException {
        when(reader.read()).thenReturn("message");
        doNothing().when(writer).writeToFile(anyString());
        doNothing().when(cache).update(anyString());

        service.start();

        verify(cache, times(1)).update(anyString());
        verify(writer, times(1)).writeToFile(anyString());
        verify(timer, times(1)).scheduleAtFixedRate(any(), anyLong(), anyLong());
    }
}