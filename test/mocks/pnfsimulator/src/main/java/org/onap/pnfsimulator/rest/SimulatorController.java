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

package org.onap.pnfsimulator.rest;

import static org.onap.pnfsimulator.message.MessageConstants.SIMULATOR_PARAMS_CONTAINER;
import static org.onap.pnfsimulator.rest.util.ResponseBuilder.MESSAGE;
import static org.onap.pnfsimulator.rest.util.ResponseBuilder.REMAINING_TIME;
import static org.onap.pnfsimulator.rest.util.ResponseBuilder.SIMULATOR_STATUS;
import static org.onap.pnfsimulator.rest.util.ResponseBuilder.TIMESTAMP;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONException;
import org.json.JSONObject;
import org.onap.pnfsimulator.message.MessageConstants;
import org.onap.pnfsimulator.message.MessageProvider;
import org.onap.pnfsimulator.rest.util.DateUtil;
import org.onap.pnfsimulator.rest.util.ResponseBuilder;
import org.onap.pnfsimulator.simulator.Simulator;
import org.onap.pnfsimulator.simulator.SimulatorFactory;
import org.onap.pnfsimulator.simulator.validation.ValidationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("/simulator")
public class SimulatorController {

    private static final Logger LOGGER = LogManager.getLogger(Simulator.class);
    private static final DateFormat RESPONSE_DATE_FORMAT = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss,SSS");

    private Simulator simulator;


    @PostMapping("start")
    public ResponseEntity start(@RequestBody String message) {

        if (simulator != null && simulator.isAlive()) {
            return ResponseBuilder
                .status(HttpStatus.BAD_REQUEST.value())
                .put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                .put(MESSAGE, "Cannot start simulator since it's already running")
                .build();
        }

        try {
            JSONObject root = new JSONObject(message);
            JSONObject simulatorParams = root.getJSONObject(SIMULATOR_PARAMS_CONTAINER);
            JSONObject messageParams = root.getJSONObject(MessageConstants.MESSAGE_PARAMS_CONTAINER);

            simulator = SimulatorFactory
                .usingMessageProvider(new MessageProvider())
                .create(simulatorParams, messageParams);

            simulator.start();

        } catch (JSONException e) {

            LOGGER.error("Cannot start simulator, invalid json format: " + e.getMessage());
            LOGGER.debug("Received json has invalid format:\n" + message);
            return ResponseBuilder
                .status(HttpStatus.BAD_REQUEST.value())
                .put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                .put(MESSAGE, "Cannot start simulator, invalid json format")
                .build();

        } catch (ValidationException e) {

            LOGGER.error("Cannot start simulator - missing mandatory parameters");
            return ResponseBuilder
                .status(HttpStatus.BAD_REQUEST.value())
                .put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                .put(MESSAGE, e.getMessage())
                .build();

        } catch (RuntimeException e) {

            LOGGER.error("Cannot start simulator - unexpected exception", e);
            return ResponseBuilder
                .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                .put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                .put(MESSAGE, "Unexpected exception: " + e.getMessage())
                .build();
        }

        return ResponseBuilder
            .status(HttpStatus.OK.value())
            .put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
            .put(MESSAGE, "Simulator started")
            .build();
    }

    @GetMapping("status")
    public ResponseEntity status() {

        if (simulator != null && simulator.isAlive()) {

            ResponseBuilder responseBuilder = ResponseBuilder
                .status(HttpStatus.OK.value())
                .put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                .put(SIMULATOR_STATUS, "RUNNING");

            if (!simulator.isEndless()) {
                responseBuilder.put(REMAINING_TIME, simulator.getRemainingTime());
            }
            return responseBuilder.build();
        } else {
            return ResponseBuilder
                .status(HttpStatus.OK.value())
                .put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                .put(SIMULATOR_STATUS, "NOT RUNNING")
                .build();
        }
    }

    @PostMapping("stop")
    public ResponseEntity stop() {

        if (simulator != null && simulator.isAlive()) {
            simulator.interrupt();

            return ResponseBuilder
                .status(HttpStatus.OK.value())
                .put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                .put(MESSAGE, "Simulator successfully stopped")
                .build();
        } else {
            return ResponseBuilder
                .status(HttpStatus.BAD_REQUEST.value())
                .put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                .put(MESSAGE, "Cannot stop simulator, because it's not running")
                .build();
        }
    }
}

