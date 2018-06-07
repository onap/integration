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

import java.time.Duration;
import java.time.Instant;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONObject;
import org.onap.pnfsimulator.simulator.client.HttpClientProvider;

public class Simulator {

    private static final Logger logger = LogManager.getLogger(HttpClientProvider.class);
    private HttpClientProvider clientProvider;
    private JSONObject messageBody;
    private Duration duration;
    private Duration interval;

    public Simulator(String vesServerUrl, JSONObject messageBody, Duration duration, Duration interval) {
        this.messageBody = messageBody;
        this.duration = duration;
        this.interval = interval;
        this.clientProvider = new HttpClientProvider(vesServerUrl);
    }

    public void start() {
        logger.info("SIMULATOR STARTED - DURATION: {}s, INTERVAL: {}s", duration.getSeconds(), interval.getSeconds());

        Instant endTime = Instant.now().plus(duration);
        while (runningTimeNotExceeded(endTime)) {
            try {
                logger.info(()-> "MESSAGE TO BE SENT:\n" + messageBody.toString(4));
                clientProvider.sendMsg(messageBody.toString());
                Thread.sleep(interval.toMillis());
            } catch (InterruptedException e) {
                logger.error("SIMULATOR INTERRUPTED");
                break;
            }
        }
        logger.info("SIMULATOR FINISHED");
    }

    private boolean runningTimeNotExceeded(Instant endTime) {
        return Instant.now().isBefore(endTime);
    }
}