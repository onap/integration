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

import com.github.fge.jsonschema.core.exceptions.ProcessingException;
import java.io.IOException;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.json.JSONObject;
import org.onap.pnfsimulator.FileProvider;
import org.onap.pnfsimulator.message.MessageProvider;
import org.onap.pnfsimulator.simulator.client.HttpClientAdapter;
import org.onap.pnfsimulator.simulator.client.HttpClientAdapterImpl;
import org.onap.pnfsimulator.simulator.validation.JSONValidator;
import org.onap.pnfsimulator.simulator.validation.NoRopFilesException;
import org.onap.pnfsimulator.simulator.validation.ValidationException;
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
    private JSONObject commonEventHeaderParams;
    private Optional<JSONObject> pnfRegistrationParams;
    private Optional<JSONObject> notificationParams;
    private String xnfUrl;
    private static final String DEFAULT_OUTPUT_SCHEMA_PATH = "json_schema/output_validator_ves_schema_30.0.1.json";
    private FileProvider fileProvider;
    private Exception thrownException = null;

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

                List<String> fileList = fileProvider.getFiles();
                MessageProvider messageProvider = new MessageProvider();
                JSONValidator validator = new JSONValidator();
                messageBody = messageProvider.createMessage(this.commonEventHeaderParams, this.pnfRegistrationParams,
                        this.notificationParams, fileList, this.xnfUrl);
                validator.validate(messageBody.toString(), DEFAULT_OUTPUT_SCHEMA_PATH);

                LOGGER.info("Message to be sent:\n" + getMessage());
                httpClient.send(messageBody.toString(), vesUrl);
                Thread.sleep(interval.toMillis());
            } catch (InterruptedException  | ValidationException | ProcessingException | IOException | NoRopFilesException e) {
                LOGGER.info("Simulation stopped due to an exception: " + e);
                thrownException = e;
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

    public Exception getThrownException() {
        return thrownException;
    }

    public long getRemainingTime() {
        return Duration.between(Instant.now(), endTime).getSeconds();
    }

    public static class Builder {

        private String vesUrl;
        private HttpClientAdapter httpClient;
        //private JSONObject messageBody;
        private Duration duration;
        private Duration interval;
        private Optional<JSONObject> notificationParams;
        private Optional<JSONObject> pnfRegistrationParams;
        private JSONObject commonEventHeaderParams;
        private String xnfUrl;
        private FileProvider fileProvider;

        private Builder() {
            this.vesUrl = "";
            this.httpClient = new HttpClientAdapterImpl();
            //this.messageBody = new JSONObject();
            this.duration = Duration.ZERO;
            this.interval = Duration.ZERO;
            this.commonEventHeaderParams = new JSONObject();
        }

        public Builder withVesUrl(String vesUrl) {
            this.vesUrl = vesUrl;
            return this;
        }

        public Builder withCustomHttpClientAdapter(HttpClientAdapter httpClient) {
            this.httpClient = httpClient;
            return this;
        }

        /*public Builder withMessageBody(JSONObject messageBody) {
            this.messageBody = messageBody;
            return this;
        }*/

        public Builder withDuration(Duration duration) {
            this.duration = duration;
            return this;
        }


        public Builder withInterval(Duration interval) {
            this.interval = interval;
            return this;
        }

        public Builder withCommonEventHeaderParams(JSONObject commonEventHeaderParams) {
            this.commonEventHeaderParams = commonEventHeaderParams;
            return this;
        }

        public Builder withNotificationParams(Optional<JSONObject> notificationParams) {
            this.notificationParams = notificationParams;
            return this;
        }

        public Builder withPnfRegistrationParams(Optional<JSONObject> pnfRegistrationParams) {
            this.pnfRegistrationParams = pnfRegistrationParams;
            return this;
        }

        public Builder withXnfUrl(String xnfUrl) {
            this.xnfUrl = xnfUrl;
            return this;
        }

        public Builder withFileProvider(FileProvider fileProvider) {
            this.fileProvider = fileProvider;
            return this;
        }

        public Simulator build() {
            Simulator simulator = new Simulator();
            simulator.vesUrl = this.vesUrl;
            simulator.httpClient = this.httpClient;
            //simulator.messageBody = this.messageBody;
            simulator.duration = this.duration;
            simulator.interval = this.interval;
            simulator.xnfUrl = this.xnfUrl;
            simulator.fileProvider = this.fileProvider;
            simulator.commonEventHeaderParams = this.commonEventHeaderParams;
            simulator.pnfRegistrationParams = this.pnfRegistrationParams;
            simulator.notificationParams = this.notificationParams;
            simulator.isEndless = duration.equals(Duration.ZERO);
            return simulator;
        }
    }
}
