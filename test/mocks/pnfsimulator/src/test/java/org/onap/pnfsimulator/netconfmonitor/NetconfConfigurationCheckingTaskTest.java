package org.onap.pnfsimulator.netconfmonitor;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.tailf.jnc.JNCException;
import java.io.IOException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationCache;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationReader;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationWriter;

class NetconfConfigurationCheckingTaskTest {

    private NetconfConfigurationCheckingTask checkingTask;

    @Mock
    private NetconfConfigurationReader reader;
    @Mock
    private NetconfConfigurationWriter writer;
    @Mock
    private NetconfConfigurationCache cache;

    @BeforeEach
    void setup() {
        MockitoAnnotations.initMocks(this);
        checkingTask = new NetconfConfigurationCheckingTask(reader, writer, cache);
    }

    @Test
    void run_should_update_configuration_when_changed() throws IOException, JNCException {
        String configuration = "newConfiguration";
        when(reader.read()).thenReturn(configuration);
        when(cache.getConfiguration()).thenReturn("oldConfiguration");

        checkingTask.run();

        verify(reader).read();
        verify(cache).getConfiguration();
        verify(writer).writeToFile(configuration);
        verify(cache).update(configuration);
    }

    @Test
    void run_should_not_update_configuration_when_same() throws IOException, JNCException {
        String configuration = "configuration";
        when(reader.read()).thenReturn(configuration);
        when(cache.getConfiguration()).thenReturn("configuration");

        checkingTask.run();

        verify(reader).read();
        verify(cache).getConfiguration();
        verify(writer, never()).writeToFile(configuration);
        verify(cache, never()).update(configuration);
    }

    @Test
    void run_should_not_take_any_action_when_failed_to_read_configuration() throws IOException, JNCException {
        when(reader.read()).thenThrow(new IOException());

        checkingTask.run();

        verify(reader).read();
        verify(cache, never()).getConfiguration();
        verify(writer, never()).writeToFile(any());
        verify(cache, never()).update(any());
    }
}