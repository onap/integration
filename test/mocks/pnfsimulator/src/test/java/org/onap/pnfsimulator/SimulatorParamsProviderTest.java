package org.onap.pnfsimulator;

import org.apache.commons.cli.ParseException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.onap.pnfsimulator.cli.SimulatorParamsProvider;
import org.onap.pnfsimulator.cli.SimulatorParams;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.Java6Assertions.assertThat;

public class SimulatorParamsProviderTest {

    SimulatorParamsProvider parser;

    @BeforeEach
    public void setUp() {
        parser = new SimulatorParamsProvider();
    }

    @Test
    public void whenParserReceiveArgLisWithTwoCorrectParametersShouldReturnCorrectStructOfParams()
        throws ParseException {
        String[] arg = new String[]{
            "-address", "http://localhost:808/eventListner/v5",
            "-config", "config.json"};
        SimulatorParams params = parser.parse(arg);
        assertThat(params.getConfigFilePath()).isEqualToIgnoringCase("config.json");
        assertThat(params.getVesAddress()).isEqualToIgnoringCase("http://localhost:808/eventListner/v5");
    }
}