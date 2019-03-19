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

package org.onap.pnfsimulator.rest;

import static org.onap.pnfsimulator.logging.MDCVariables.INSTANCE_UUID;
import static org.onap.pnfsimulator.logging.MDCVariables.INVOCATION_ID;
import static org.onap.pnfsimulator.logging.MDCVariables.REQUEST_ID;
import static org.onap.pnfsimulator.logging.MDCVariables.RESPONSE_CODE;
import static org.onap.pnfsimulator.logging.MDCVariables.SERVICE_NAME;
import static org.onap.pnfsimulator.logging.MDCVariables.X_INVOCATION_ID;
import static org.onap.pnfsimulator.logging.MDCVariables.X_ONAP_REQUEST_ID;
import static org.onap.pnfsimulator.message.MessageConstants.COMMON_EVENT_HEADER_PARAMS;
import static org.onap.pnfsimulator.message.MessageConstants.SIMULATOR_PARAMS;
import static org.onap.pnfsimulator.rest.util.ResponseBuilder.MESSAGE;
import static org.onap.pnfsimulator.rest.util.ResponseBuilder.REMAINING_TIME;
import static org.onap.pnfsimulator.rest.util.ResponseBuilder.SIMULATOR_STATUS;
import static org.onap.pnfsimulator.rest.util.ResponseBuilder.TIMESTAMP;
import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR;
import static org.springframework.http.HttpStatus.OK;
import com.github.fge.jsonschema.core.exceptions.ProcessingException;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Optional;
import java.util.UUID;
import org.json.JSONException;
import org.json.JSONObject;
import org.onap.pnfsimulator.message.MessageConstants;
import org.onap.pnfsimulator.rest.util.DateUtil;
import org.onap.pnfsimulator.rest.util.ResponseBuilder;
import org.onap.pnfsimulator.simulator.Simulator;
import org.onap.pnfsimulator.simulator.SimulatorFactory;
import org.onap.pnfsimulator.simulator.validation.JSONValidator;
import org.onap.pnfsimulator.simulator.validation.ValidationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.slf4j.Marker;
import org.slf4j.MarkerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/simulator")
public class SimulatorController {

    private static final Logger LOGGER = LoggerFactory.getLogger(Simulator.class);
    private static final DateFormat RESPONSE_DATE_FORMAT = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss,SSS");
    private final Marker ENTRY = MarkerFactory.getMarker("ENTRY");
    private Simulator simulator;
    private JSONValidator validator;
    private SimulatorFactory factory;

    @Autowired
    public SimulatorController(JSONValidator validator, SimulatorFactory factory) {
        this.validator = validator;
        this.factory = factory;
    }

    @PostMapping("start")
    public ResponseEntity start(@RequestHeader HttpHeaders headers, @RequestBody String message) {
        MDC.put(REQUEST_ID, headers.getFirst(X_ONAP_REQUEST_ID));
        MDC.put(INVOCATION_ID, headers.getFirst(X_INVOCATION_ID));
        MDC.put(INSTANCE_UUID, UUID.randomUUID().toString());
        MDC.put(SERVICE_NAME, "/simulator/start");
        LOGGER.info(ENTRY, "Simulator starting");

        if (isSimulatorRunning()) {
            MDC.put(RESPONSE_CODE, BAD_REQUEST.toString());
            return ResponseBuilder.status(BAD_REQUEST).put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                    .put(MESSAGE, "Cannot start simulator since it's already running").build();
        }

        try {
            validator.validate(message, "json_schema/input_validator.json");
            JSONObject root = new JSONObject(message);
            JSONObject simulatorParams = root.getJSONObject(SIMULATOR_PARAMS);
            JSONObject commonEventHeaderParams = root.getJSONObject(COMMON_EVENT_HEADER_PARAMS);
            Optional<JSONObject> pnfRegistrationFields = root.has(MessageConstants.PNF_REGISTRATION_PARAMS)
                    ? Optional.of(root.getJSONObject(MessageConstants.PNF_REGISTRATION_PARAMS))
                    : Optional.empty();
            Optional<JSONObject> notificationFields = root.has(MessageConstants.NOTIFICATION_PARAMS)
                    ? Optional.of(root.getJSONObject(MessageConstants.NOTIFICATION_PARAMS))
                    : Optional.empty();
            simulator =
                    factory.create(simulatorParams, commonEventHeaderParams, pnfRegistrationFields, notificationFields);
            simulator.start();

            MDC.put(RESPONSE_CODE, OK.toString());
            return ResponseBuilder.status(OK).put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                    .put(MESSAGE, "Simulator started").build();

        } catch (JSONException e) {
            MDC.put(RESPONSE_CODE, BAD_REQUEST.toString());
            LOGGER.warn("Cannot start simulator, invalid json format: {}", e.getMessage());
            LOGGER.debug("Received json has invalid format", e);
            return ResponseBuilder.status(BAD_REQUEST).put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                    .put(MESSAGE, "Cannot start simulator, invalid json format").build();

        } catch (ProcessingException | ValidationException | IOException e) {
            MDC.put(RESPONSE_CODE, BAD_REQUEST.toString());
            LOGGER.warn("Json validation failed: {}", e.getMessage());
            return ResponseBuilder.status(BAD_REQUEST).put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                    .put(MESSAGE, "Cannot start simulator - Json format is not compatible with schema definitions")
                    .build();

        } catch (Exception e) {
            MDC.put(RESPONSE_CODE, INTERNAL_SERVER_ERROR.toString());
            LOGGER.error("Cannot start simulator - unexpected exception", e);
            return ResponseBuilder.status(INTERNAL_SERVER_ERROR)
                    .put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                    .put(MESSAGE, "Unexpected exception: " + e.getMessage()).build();
        } finally {
            MDC.clear();
        }
    }

    @PostMapping("startmassmode")
    public ResponseEntity startmassmode(@RequestHeader HttpHeaders headers, @RequestBody String message) {
        MDC.put(REQUEST_ID, headers.getFirst(X_ONAP_REQUEST_ID));
        MDC.put(INVOCATION_ID, headers.getFirst(X_INVOCATION_ID));
        MDC.put(INSTANCE_UUID, UUID.randomUUID().toString());
        MDC.put(SERVICE_NAME, "/simulator/start");
        LOGGER.info(ENTRY, "Simulator starting");

        if (isSimulatorRunning()) {
            MDC.put(RESPONSE_CODE, BAD_REQUEST.toString());
            return ResponseBuilder.status(BAD_REQUEST).put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                    .put(MESSAGE, "Cannot start simulator since it's already running").build();
        }

        try {
            validator.validate(message, "json_schema/input_validator.json");
            JSONObject root = new JSONObject(message);
            JSONObject simulatorParams = root.getJSONObject(SIMULATOR_PARAMS);
            JSONObject commonEventHeaderParams = root.getJSONObject(COMMON_EVENT_HEADER_PARAMS);
            Optional<JSONObject> pnfRegistrationFields = root.has(MessageConstants.PNF_REGISTRATION_PARAMS)
                    ? Optional.of(root.getJSONObject(MessageConstants.PNF_REGISTRATION_PARAMS))
                    : Optional.empty();
            Optional<JSONObject> notificationFields = root.has(MessageConstants.NOTIFICATION_PARAMS)
                    ? Optional.of(root.getJSONObject(MessageConstants.NOTIFICATION_PARAMS))
                    : Optional.empty();
            simulator =
                    factory.create(simulatorParams, commonEventHeaderParams, pnfRegistrationFields, notificationFields);
            simulator.start();

            MDC.put(RESPONSE_CODE, OK.toString());
            return ResponseBuilder.status(OK).put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                    .put(MESSAGE, "Simulator started").build();

        } catch (JSONException e) {
            MDC.put(RESPONSE_CODE, BAD_REQUEST.toString());
            LOGGER.warn("Cannot start simulator, invalid json format: {}", e.getMessage());
            LOGGER.debug("Received json has invalid format", e);
            return ResponseBuilder.status(BAD_REQUEST).put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                    .put(MESSAGE, "Cannot start simulator, invalid json format").build();

        } catch (ProcessingException | ValidationException | IOException e) {
            MDC.put(RESPONSE_CODE, BAD_REQUEST.toString());
            LOGGER.warn("Json validation failed: {}", e.getMessage());
            return ResponseBuilder.status(BAD_REQUEST).put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                    .put(MESSAGE, "Cannot start simulator - Json format is not compatible with schema definitions")
                    .build();

        } catch (Exception e) {
            MDC.put(RESPONSE_CODE, INTERNAL_SERVER_ERROR.toString());
            LOGGER.error("Cannot start simulator - unexpected exception", e);
            return ResponseBuilder.status(INTERNAL_SERVER_ERROR)
                    .put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                    .put(MESSAGE, "Unexpected exception: " + e.getMessage()).build();
        } finally {
            MDC.clear();
        }
    }



    @GetMapping("status")
    public ResponseEntity status() {
        if (isSimulatorRunning()) {
            ResponseBuilder responseBuilder = ResponseBuilder.status(OK)
                    .put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT)).put(SIMULATOR_STATUS, "RUNNING");

            return !simulator.isEndless() ? responseBuilder.put(REMAINING_TIME, simulator.getRemainingTime()).build()
                    : responseBuilder.build();
        } else {
            return ResponseBuilder.status(OK).put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                    .put(SIMULATOR_STATUS, "NOT RUNNING").build();
        }
    }

    @PostMapping("stop")
    public ResponseEntity stop() {
        if (isSimulatorRunning()) {
            simulator.interrupt();

            return ResponseBuilder.status(OK).put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                    .put(MESSAGE, "Simulator successfully stopped").build();
        } else {
            return ResponseBuilder.status(BAD_REQUEST).put(TIMESTAMP, DateUtil.getTimestamp(RESPONSE_DATE_FORMAT))
                    .put(MESSAGE, "Cannot stop simulator, because it's not running").build();
        }
    }

    private boolean isSimulatorRunning() {
        return simulator != null && simulator.isAlive();
    }
}

