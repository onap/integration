/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2018-2019 NOKIA Intellectual Property. All rights reserved.
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

import com.github.fge.jsonschema.core.exceptions.ProcessingException;
import org.json.JSONObject;
import org.onap.pnfsimulator.message.MessageProvider;
import org.onap.pnfsimulator.simulator.validation.JSONValidator;
import org.onap.pnfsimulator.simulator.validation.ValidationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.time.Duration;

import static java.lang.Integer.parseInt;
import static org.onap.pnfsimulator.message.MessageConstants.MESSAGE_INTERVAL;
import static org.onap.pnfsimulator.message.MessageConstants.TEST_DURATION;
import static org.onap.pnfsimulator.message.MessageConstants.VES_SERVER_URL;

@Service
public class SimulatorFactory {

    private static final String DEFAULT_OUTPUT_SCHEMA_PATH = "json_schema/output_validator_ves_schema_30.0.1.json";

    private MessageProvider messageProvider;
    private JSONValidator validator;

    @Autowired
    public SimulatorFactory(MessageProvider messageProvider, JSONValidator validator) {
        this.messageProvider = messageProvider;
        this.validator = validator;
    }

    public Simulator createSimulatorWithNotification(JSONObject simulatorParams, JSONObject commonEventHeaderParams,
                                                     JSONObject notificationParams)
            throws ProcessingException, IOException, ValidationException {
        JSONObject messageBody = messageProvider
                .createMessageWithNotification(commonEventHeaderParams, notificationParams);
        return createSimulatorWithMessage(simulatorParams, messageBody);
    }

    public Simulator createSimulatorWithPnfRegistration(JSONObject simulatorParams, JSONObject commonEventHeaderParams,
                                                        JSONObject pnfRegistrationParams)
            throws ProcessingException, IOException, ValidationException {
        JSONObject messageBody = messageProvider
                .createMessageWithPnfRegistration(commonEventHeaderParams, pnfRegistrationParams);
        return createSimulatorWithMessage(simulatorParams, messageBody);
    }

    private Simulator createSimulatorWithMessage(JSONObject simulatorParams, JSONObject messageBody)
            throws ValidationException, ProcessingException, IOException {
        Duration duration = Duration.ofSeconds(parseInt(simulatorParams.getString(TEST_DURATION)));
        Duration interval = Duration.ofSeconds(parseInt(simulatorParams.getString(MESSAGE_INTERVAL)));
        String vesUrl = simulatorParams.getString(VES_SERVER_URL);
        validator.validate(messageBody.toString(), DEFAULT_OUTPUT_SCHEMA_PATH);

        return Simulator.builder()
                .withVesUrl(vesUrl)
                .withDuration(duration)
                .withInterval(interval)
                .withMessageBody(messageBody)
                .build();
    }
}