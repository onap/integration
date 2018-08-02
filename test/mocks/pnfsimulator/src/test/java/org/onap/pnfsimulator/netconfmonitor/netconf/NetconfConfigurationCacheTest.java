package org.onap.pnfsimulator.netconfmonitor.netconf;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

public class NetconfConfigurationCacheTest {

    private static final String CONFIGURATION = "sampleConfiguration";

    @Test
    void changeConfigurationAfterUpdate() {
        NetconfConfigurationCache configurationCache = new NetconfConfigurationCache();
        configurationCache.update(CONFIGURATION);

        assertEquals(CONFIGURATION, configurationCache.getConfiguration());
    }
}