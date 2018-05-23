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

package org.onap.pnfsimulator;

import java.io.IOException;
import org.apache.commons.cli.ParseException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.onap.pnfsimulator.cli.SimulatorParamsProvider;
import org.onap.pnfsimulator.cli.SimulatorParams;
import org.onap.pnfsimulator.message.MessageProvider;
import org.onap.pnfsimulator.simulator.SimulatorFactory;
import org.onap.pnfsimulator.simulator.validation.ParamsValidator;
import org.onap.pnfsimulator.simulator.validation.ValidationException;

public class Main {

    private static Logger logger = LogManager.getLogger(Main.class);
    private static SimulatorFactory simulatorFactory =
        new SimulatorFactory(MessageProvider.getInstance());

    public static void main(String[] args) {

        try {

            SimulatorParams params = new SimulatorParamsProvider().parse(args);
            simulatorFactory
                .create(params.getVesAddress(), params.getConfigFilePath())
                .start();

        } catch (IOException e) {
            logger.error("Invalid config file format", e);
        } catch (ParseException e) {
            logger.error("Invalid cli params", e);
        } catch (ValidationException e){
            logger.error(e);
        }
    }
}
