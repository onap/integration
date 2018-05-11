package org.onap.pnfsimulator.cli;

import java.util.Objects;

public class SimulatorParams {

    private String vesAddress;
    private String configFilePath;

    public SimulatorParams(String vesAddress, String configFilePath) {
        this.vesAddress = vesAddress;
        this.configFilePath = configFilePath;
    }

    public String getVesAddress() {
        return vesAddress;
    }

    public String getConfigFilePath() {
        return configFilePath;
    }

    @Override
    public String toString() {
        return String.format("VES address=%s, Configuration file=%s", vesAddress, configFilePath);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof SimulatorParams)) {
            return false;
        }
        SimulatorParams params = (SimulatorParams) o;
        return Objects.equals(vesAddress, params.vesAddress) &&
            Objects.equals(configFilePath, params.configFilePath);
    }

    @Override
    public int hashCode() {
        return Objects.hash(vesAddress, configFilePath);
    }
}
