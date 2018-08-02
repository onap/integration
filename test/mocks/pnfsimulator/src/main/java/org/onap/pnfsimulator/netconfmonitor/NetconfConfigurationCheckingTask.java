package org.onap.pnfsimulator.netconfmonitor;

import com.tailf.jnc.JNCException;
import java.io.IOException;
import java.util.TimerTask;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationCache;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationReader;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationWriter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class NetconfConfigurationCheckingTask extends TimerTask {

    private static final Logger LOGGER = LoggerFactory.getLogger(NetconfConfigurationCheckingTask.class);

    private final NetconfConfigurationReader reader;
    private final NetconfConfigurationWriter writer;
    private final NetconfConfigurationCache cache;

    public NetconfConfigurationCheckingTask(NetconfConfigurationReader reader,
        NetconfConfigurationWriter writer,
        NetconfConfigurationCache cache) {
        this.reader = reader;
        this.writer = writer;
        this.cache = cache;
    }

    @Override
    public void run() {
        try {
            String currentConfiguration = reader.read();
            if (!currentConfiguration.equals(cache.getConfiguration())) {
                LOGGER.info("Configuration has changed, new configuration:\n\n{}", currentConfiguration);
                writer.writeToFile(currentConfiguration);
                cache.update(currentConfiguration);
            }
        } catch (IOException | JNCException e) {
            LOGGER.warn("Error during configuration reading: {}", e.getMessage());
        }
    }
}
