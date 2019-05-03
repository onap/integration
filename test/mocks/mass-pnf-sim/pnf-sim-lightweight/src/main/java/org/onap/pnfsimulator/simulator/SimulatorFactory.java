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
import java.time.Duration;
import java.util.Optional;
import org.json.JSONObject;
import org.onap.pnfsimulator.ConfigurationProvider;
import org.onap.pnfsimulator.FileProvider;
import org.onap.pnfsimulator.PnfSimConfig;
import org.springframework.stereotype.Service;

@Service
public class SimulatorFactory {

    public Simulator create(JSONObject simulatorParams, JSONObject commonEventHeaderParams,
            Optional<JSONObject> pnfRegistrationParams, Optional<JSONObject> notificationParams) {
        PnfSimConfig configuration = ConfigurationProvider.getConfigInstance();

        String xnfUrl = null;
        if (configuration.getTypefileserver().equals("sftp")) {
            xnfUrl = configuration.getUrlsftp() + "/";
        } else if (configuration.getTypefileserver().equals("ftps")) {
            xnfUrl = configuration.getUrlftps() + "/";
        }

        String urlVes = configuration.getUrlves();
        Duration duration = Duration.ofSeconds(parseInt(simulatorParams.getString(TEST_DURATION)));
        Duration interval = Duration.ofSeconds(parseInt(simulatorParams.getString(MESSAGE_INTERVAL)));

        return Simulator.builder().withVesUrl(urlVes).withXnfUrl(xnfUrl).withDuration(duration)
                .withFileProvider(new FileProvider()).withCommonEventHeaderParams(commonEventHeaderParams)
                .withNotificationParams(notificationParams).withPnfRegistrationParams(pnfRegistrationParams)
                .withInterval(interval).build();
    }
}
