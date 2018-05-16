/*-
 * ============LICENSE_START=======================================================
 * org.onap.integration
 * ================================================================================
 * Copyright (C) 2017 AT&T Intellectual Property. All rights reserved.
 * ================================================================================
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============LICENSE_END=========================================================
 */

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