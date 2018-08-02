package org.onap.pnfsimulator.netconfmonitor.netconf;

public class NetconfConfigurationCache {

    private String configuration = "";

    public String getConfiguration() {
        return configuration;
    }

    public void update(String configuration) {
        this.configuration = configuration;
    }
}
