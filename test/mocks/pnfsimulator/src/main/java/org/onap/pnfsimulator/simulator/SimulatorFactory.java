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

package org.onap.pnfsimulator.simulator;

import static java.lang.Integer.*;
import static org.onap.pnfsimulator.message.MessageConstants.MESSAGE_INTERVAL;
import static org.onap.pnfsimulator.message.MessageConstants.TEST_DURATION;
import static org.onap.pnfsimulator.message.MessageConstants.VES_SERVER_URL;

import java.time.Duration;
import org.json.JSONObject;
import org.onap.pnfsimulator.message.MessageProvider;
import org.onap.pnfsimulator.simulator.validation.ParamsValidator;
import org.onap.pnfsimulator.simulator.validation.ValidationException;

public class SimulatorFactory {

    private MessageProvider messageProvider;

    public static SimulatorFactory usingMessageProvider(MessageProvider messageProvider) {
        return new SimulatorFactory(messageProvider);
    }

    private SimulatorFactory(MessageProvider messageProvider) {
        this.messageProvider = messageProvider;
    }

    public Simulator create(JSONObject simulatorParams, JSONObject messageParams) throws ValidationException {

        ParamsValidator.forParams(simulatorParams, messageParams).validate();

        Duration duration = Duration.ofSeconds(parseInt(simulatorParams.getString(TEST_DURATION)));
        Duration interval = Duration.ofSeconds(parseInt(simulatorParams.getString(MESSAGE_INTERVAL)));
        String vesServerUrl = simulatorParams.getString(VES_SERVER_URL);

        JSONObject messageBody = messageProvider.createMessage(messageParams);
        return new Simulator(vesServerUrl, messageBody, duration, interval);
    }
}