/*-
 * ============LICENSE_START=======================================================
 * org.onap.integration
 * ================================================================================
 * Copyright (C) 2018 NOKIA Intellectual Property. All rights reserved.
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

package org.onap.pnfsimulator.cli;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

public class SimulatorParamsProvider {

    private static final String CLI_VAR_VES_ADDRESS = "address";
    private static final String CLI_VAR_CONFIG_FILE_PATH = "config";
    private static final String ENV_VAR_VES_ADDRESS = "VES_ADDRESS";
    private static final String ENV_VAR_CONFIG_FILE_PATH = "CONFIG_FILE_PATH";

    private Options options;
    private CommandLineParser parser;

    public SimulatorParamsProvider() {
        createOptions();
        parser = new DefaultParser();
    }

    public SimulatorParams parse(String[] arg) throws ParseException {
        CommandLine line = parser.parse(options, arg);
        return new SimulatorParams(
            line.getOptionValue(CLI_VAR_VES_ADDRESS, System.getenv().get(ENV_VAR_VES_ADDRESS)),
            line.getOptionValue(CLI_VAR_CONFIG_FILE_PATH, System.getenv().get(ENV_VAR_CONFIG_FILE_PATH)));
    }

    private void createOptions() {
        options = new Options();

        Option vesCollectorUlrOpt = new Option(CLI_VAR_VES_ADDRESS, true, "VES collector URL");
        options.addOption(vesCollectorUlrOpt);

        Option simulatorConfigFilePathOpt = new Option(CLI_VAR_CONFIG_FILE_PATH, true, "Simulator configuration file location.");
        options.addOption(simulatorConfigFilePathOpt);
    }
}
