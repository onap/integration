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
import org.onap.pnfsimulator.simulator.client.HttpClientAdapter;

public class Simulator extends Thread {

    private static final Logger LOGGER = LogManager.getLogger(Simulator.class);
    private HttpClientAdapter clientProvider;
    private JSONObject messageBody;
    private Instant endTime;
    private Duration duration;
    private Duration interval;
    private final boolean isEndless;

    public Simulator(String vesServerUrl, JSONObject messageBody, Duration duration, Duration interval) {
        this.messageBody = messageBody;
        this.duration = duration;
        this.interval = interval;
        this.clientProvider = new HttpClientAdapter(vesServerUrl);
        this.isEndless = duration.getSeconds() == 0;
    }

    public void run() {
        LOGGER.info("Simulation started - duration: " + getDuration() + ", interval: {}s", interval.getSeconds());

        endTime = Instant.now().plus(duration);
        boolean isEndless = isEndless();
        while (isEndless || runningTimeNotExceeded()) {
            try {
                LOGGER.debug("Message to be sent:\n" + messageBody.toString(4));
                clientProvider.sendMsg(messageBody.toString());
                Thread.sleep(interval.toMillis());
            } catch (InterruptedException e) {
                LOGGER.info("Simulation interrupted");
                return;
            }
        }
        LOGGER.info("Simulation finished");
    }

    public boolean isEndless() {
        return isEndless;
    }

    private String getDuration() {
        return isEndless() ? "infinity" : duration.getSeconds() + "s";
    }

    private boolean runningTimeNotExceeded() {
        return Instant.now().isBefore(endTime);
    }

    public long getRemainingTime(){
        return Duration.between(Instant.now(), endTime).getSeconds();
    }
    public String getMessage(){
        return messageBody.toString(4);
    }
}