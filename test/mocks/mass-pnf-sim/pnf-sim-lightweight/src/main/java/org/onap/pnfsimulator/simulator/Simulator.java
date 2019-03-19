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

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import org.json.JSONObject;
import org.onap.pnfsimulator.simulator.client.HttpClientAdapter;
import org.onap.pnfsimulator.simulator.client.HttpClientAdapterImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.slf4j.Marker;
import org.slf4j.MarkerFactory;

public class Simulator extends Thread {

    private static final Logger LOGGER = LoggerFactory.getLogger(Simulator.class);
    private final Marker EXIT = MarkerFactory.getMarker("EXIT");
    private Map<String, String> contextMap = MDC.getCopyOfContextMap();
    private boolean isEndless;
    private String vesUrl;
    private HttpClientAdapter httpClient;
    private JSONObject messageBody;
    private Duration duration;
    private Duration interval;
    private Instant endTime;

    private Simulator() {}

    public static Builder builder() {
        return new Builder();
    }

    @Override
    public void run() {
        setMdcContextMap(contextMap);
        LOGGER.info("Simulation started - duration: {}, interval: {}s", getDuration(), interval.getSeconds());
        endTime = Instant.now().plus(duration);
        while (isEndless || runningTimeNotExceeded()) {
            try {
                LOGGER.info("Message to be sent:\n" + getMessage());
                httpClient.send(messageBody.toString(), vesUrl);
                Thread.sleep(interval.toMillis());
            } catch (InterruptedException e) {
                LOGGER.info("Simulation interrupted");
                return;
            }
        }
        LOGGER.info(EXIT, "Simulation finished");
        MDC.clear();
    }

    private void setMdcContextMap(Map<String, String> mdcContextMap) {
        if (mdcContextMap != null)
            MDC.setContextMap(mdcContextMap);
    }

    private String getMessage() {
        return messageBody.toString(4);
    }

    private String getDuration() {
        return isEndless() ? "infinity" : duration.getSeconds() + "s";
    }

    private boolean runningTimeNotExceeded() {
        return Instant.now().isBefore(endTime);
    }

    public boolean isEndless() {
        return isEndless;
    }

    public long getRemainingTime() {
        return Duration.between(Instant.now(), endTime).getSeconds();
    }

    public static class Builder {

        private String vesUrl;
        private HttpClientAdapter httpClient;
        private JSONObject messageBody;
        private Duration duration;
        private Duration interval;

        private Builder() {
            this.vesUrl = "";
            this.httpClient = new HttpClientAdapterImpl();
            this.messageBody = new JSONObject();
            this.duration = Duration.ZERO;
            this.interval = Duration.ZERO;
        }

        public Builder withVesUrl(String vesUrl) {
            this.vesUrl = vesUrl;
            return this;
        }

        public Builder withCustomHttpClientAdapter(HttpClientAdapter httpClient) {
            this.httpClient = httpClient;
            return this;
        }

        public Builder withMessageBody(JSONObject messageBody) {
            this.messageBody = messageBody;
            return this;
        }

        public Builder withDuration(Duration duration) {
            this.duration = duration;
            return this;
        }


        public Builder withInterval(Duration interval) {
            this.interval = interval;
            return this;
        }

        public Simulator build() {
            Simulator simulator = new Simulator();
            simulator.vesUrl = this.vesUrl;
            simulator.httpClient = this.httpClient;
            simulator.messageBody = this.messageBody;
            simulator.duration = this.duration;
            simulator.interval = this.interval;
            simulator.isEndless = duration.equals(Duration.ZERO);
            return simulator;
        }
    }
}
