package org.onap.pnfsimulator.netconfmonitor;

import com.tailf.jnc.JNCException;
import java.io.IOException;
import java.util.Timer;
import javax.annotation.PostConstruct;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationCache;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationReader;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationWriter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class NetconfMonitorService {
    private static final Logger LOGGER = LoggerFactory.getLogger(NetconfMonitorService.class);
    private static final long timePeriod = 1000L;
    private static final long startDelay = 0;

    private Timer timer;
    private NetconfConfigurationReader reader;
    private NetconfConfigurationWriter writer;
    private NetconfConfigurationCache cache;

    @Autowired
    public NetconfMonitorService(Timer timer,
        NetconfConfigurationReader reader,
        NetconfConfigurationWriter writer,
        NetconfConfigurationCache cache) {
        this.timer = timer;
        this.reader = reader;
        this.writer = writer;
        this.cache = cache;
    }

    @PostConstruct
    public void start() {
        setStartConfiguration();
        NetconfConfigurationCheckingTask task = new NetconfConfigurationCheckingTask(reader, writer, cache);
        timer.scheduleAtFixedRate(task, startDelay, timePeriod);
    }

    private void setStartConfiguration() {
        try {
            String configuration = reader.read();
            writer.writeToFile(configuration);
            cache.update(configuration);
        } catch (IOException | JNCException e) {
            LOGGER.warn("Error during configuration reading: {}", e.getMessage());
        }
    }
}
