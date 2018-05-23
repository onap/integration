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

import static org.onap.pnfsimulator.message.MessageConstants.MESSAGE_INTERVAL;
import static org.onap.pnfsimulator.message.MessageConstants.TEST_DURATION;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.List;
import org.apache.commons.io.FileUtils;
import org.json.JSONObject;
import org.onap.pnfsimulator.message.MessageProvider;
import org.onap.pnfsimulator.simulator.validation.ParamsValidator;
import org.onap.pnfsimulator.simulator.validation.ValidationException;

public class SimulatorFactory {

    private MessageProvider messageProvider;

    public SimulatorFactory(MessageProvider messageProvider) {
        this.messageProvider = messageProvider;
    }

    public Simulator create(String vesServerUrl, String configFilePath) throws IOException, ValidationException {

        String configJson = FileUtils.readFileToString(new File(configFilePath), StandardCharsets.UTF_8);
        JSONObject configObject = new JSONObject(configJson);
        ParamsValidator.forObject(configObject).validate();

        Duration duration = Duration.ofSeconds(parseJsonField(configObject, TEST_DURATION));
        Duration interval = Duration.ofSeconds(parseJsonField(configObject, MESSAGE_INTERVAL));
        JSONObject messageBody = messageProvider.createMessage(configObject);
        return new Simulator(vesServerUrl, messageBody, duration, interval);
    }

    private int parseJsonField(JSONObject json, String fieldName) {
        return Integer.parseInt((String) json.remove(fieldName));
    }
}