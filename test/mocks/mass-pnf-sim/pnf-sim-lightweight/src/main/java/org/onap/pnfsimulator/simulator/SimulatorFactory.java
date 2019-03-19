/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================ Copyright (C)
 * 2018 NOKIA Intellectual Property. All rights reserved.
 * ================================================================================ Licensed under
 * the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License. ============LICENSE_END=========================================================
 */

package org.onap.pnfsimulator.simulator;

import static java.lang.Integer.parseInt;
import static org.onap.pnfsimulator.message.MessageConstants.MESSAGE_INTERVAL;
import static org.onap.pnfsimulator.message.MessageConstants.TEST_DURATION;
import static org.onap.pnfsimulator.message.MessageConstants.VES_SERVER_URL;
import com.github.fge.jsonschema.core.exceptions.ProcessingException;
import java.io.IOException;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Optional;
import org.json.JSONArray;
import org.json.JSONObject;
import org.onap.pnfsimulator.ConfigurationProvider;
import org.onap.pnfsimulator.FileProvider;
import org.onap.pnfsimulator.PnfSimConfig;
import org.onap.pnfsimulator.message.MessageProvider;
import org.onap.pnfsimulator.simulator.validation.JSONValidator;
import org.onap.pnfsimulator.simulator.validation.ValidationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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

    public Simulator create(JSONObject simulatorParams, JSONObject commonEventHeaderParams,
            Optional<JSONObject> pnfRegistrationParams, Optional<JSONObject> notificationParams)
            throws ProcessingException, IOException, ValidationException {
        Duration duration = Duration.ofSeconds(parseInt(simulatorParams.getString(TEST_DURATION)));
        Duration interval = Duration.ofSeconds(parseInt(simulatorParams.getString(MESSAGE_INTERVAL)));
        String vesUrl = simulatorParams.getString(VES_SERVER_URL);

        JSONObject messageBody =
                messageProvider.createMessage(commonEventHeaderParams, pnfRegistrationParams, notificationParams);
        validator.validate(messageBody.toString(), DEFAULT_OUTPUT_SCHEMA_PATH);

        JSONArray messageBodyArray = new JSONArray();

        PnfSimConfig configuration = ConfigurationProvider.getConfigInstance();
        String xnfUrl = configuration.getIpsftp() + "/";

        ArrayList<String> fileList = FileProvider.getFiles();

        // for (String f : fileList) {
        // System.out.println("f processed from fileList: " + f.toString());
        // JSONObject vesEvent = messageProvider.createOneVes(commonEventHeaderParams,
        // pnfRegistrationParams,
        // notificationParams, url, f);
        // messageBodyArray.put(vesEvent);
        // }

        String fileName = fileList.get(1);
        System.out.println("f processed from fileList: " + fileName.toString());
        JSONObject vesEvent = messageProvider.createOneVesEvent(xnfUrl, fileName);

        return Simulator.builder().withVesUrl(configuration.getVesip()).withDuration(duration).withInterval(interval)
                .withMessageBody(vesEvent).build();

    }
}
