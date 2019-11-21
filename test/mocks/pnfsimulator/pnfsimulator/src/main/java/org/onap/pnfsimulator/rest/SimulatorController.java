/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2018 Nokia. All rights reserved.
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

import com.google.common.collect.ImmutableMap;
import com.google.gson.JsonSyntaxException;
import org.json.JSONException;
import org.onap.pnfsimulator.event.EventData;
import org.onap.pnfsimulator.event.EventDataService;
import org.onap.pnfsimulator.rest.model.FullEvent;
import org.onap.pnfsimulator.rest.model.SimulatorRequest;
import org.onap.pnfsimulator.rest.util.DateUtil;
import org.onap.pnfsimulator.rest.util.ResponseBuilder;
import org.onap.pnfsimulator.simulator.SimulatorService;
import org.onap.pnfsimulator.simulatorconfig.SimulatorConfig;
import org.quartz.SchedulerException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.slf4j.Marker;
import org.slf4j.MarkerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.io.IOException;
import java.net.MalformedURLException;
import java.security.GeneralSecurityException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.onap.pnfsimulator.logging.MDCVariables.INSTANCE_UUID;
import static org.onap.pnfsimulator.logging.MDCVariables.INVOCATION_ID;
import static org.onap.pnfsimulator.logging.MDCVariables.REQUEST_ID;
import static org.onap.pnfsimulator.logging.MDCVariables.RESPONSE_CODE;
import static org.onap.pnfsimulator.logging.MDCVariables.SERVICE_NAME;
import static org.onap.pnfsimulator.logging.MDCVariables.X_INVOCATION_ID;
import static org.onap.pnfsimulator.logging.MDCVariables.X_ONAP_REQUEST_ID;
import static org.onap.pnfsimulator.rest.util.ResponseBuilder.MESSAGE;
import static org.onap.pnfsimulator.rest.util.ResponseBuilder.TIMESTAMP;
import static org.springframework.http.HttpStatus.ACCEPTED;
import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR;
import static org.springframework.http.HttpStatus.NOT_FOUND;
import static org.springframework.http.HttpStatus.OK;

@RestController
@RequestMapping("/simulator")
public class SimulatorController {

    private static final Logger LOGGER = LoggerFactory.getLogger(SimulatorController.class);
    private static final Marker ENTRY = MarkerFactory.getMarker("ENTRY");
    private static final String INCORRECT_TEMPLATE_MESSAGE = "Cannot start simulator, template %s is not in valid format: %s";
    private static final String NOT_EXISTING_TEMPLATE = "Cannot start simulator - template %s not found.";
    private final DateFormat responseDateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss,SSS");
    private final SimulatorService simulatorService;
    private EventDataService eventDataService;

    @Autowired
    public SimulatorController(SimulatorService simulatorService,
                               EventDataService eventDataService) {
        this.simulatorService = simulatorService;
        this.eventDataService = eventDataService;
    }

    @PostMapping("test")
    @Deprecated
    public ResponseEntity test(@Valid @RequestBody SimulatorRequest simulatorRequest) {
        MDC.put("test", "test");
        LOGGER.info(ENTRY, simulatorRequest.toString());
        return buildResponse(OK, ImmutableMap.of(MESSAGE, "message1234"));
    }

    @PostMapping(value = "start")
    public ResponseEntity start(@RequestHeader HttpHeaders headers,
                                @Valid @RequestBody SimulatorRequest triggerEventRequest) {
        logContextHeaders(headers, "/simulator/start");
        LOGGER.info(ENTRY, "Simulator started");

        try {
            return processRequest(triggerEventRequest);

        } catch (JSONException | JsonSyntaxException e) {
            MDC.put(RESPONSE_CODE, BAD_REQUEST.toString());
            LOGGER.warn("Cannot trigger event, invalid json format: {}", e.getMessage());
            LOGGER.debug("Received json has invalid format", e);
            return buildResponse(BAD_REQUEST, ImmutableMap.of(MESSAGE, String
                    .format(INCORRECT_TEMPLATE_MESSAGE, triggerEventRequest.getTemplateName(),
                            e.getMessage())));
        } catch (GeneralSecurityException e ){
            MDC.put(RESPONSE_CODE, INTERNAL_SERVER_ERROR.toString() );
            LOGGER.error("Client certificate validation failed: {}", e.getMessage());
            return buildResponse(INTERNAL_SERVER_ERROR,
                    ImmutableMap.of(MESSAGE, "Invalid or misconfigured client certificate"));
        }
         catch (IOException e) {
            MDC.put(RESPONSE_CODE, BAD_REQUEST.toString());
            LOGGER.warn("Json validation failed: {}", e.getMessage());
            return buildResponse(BAD_REQUEST,
                    ImmutableMap.of(MESSAGE, String.format(NOT_EXISTING_TEMPLATE, triggerEventRequest.getTemplateName())));
        } catch (Exception e) {
            MDC.put(RESPONSE_CODE, INTERNAL_SERVER_ERROR.toString());
            LOGGER.error("Cannot trigger event - unexpected exception", e);
            return buildResponse(INTERNAL_SERVER_ERROR,
                    ImmutableMap.of(MESSAGE, "Unexpected exception: " + e.getMessage()));
        } finally {
            MDC.clear();
        }
    }

    @GetMapping("all-events")
    @Deprecated
    public ResponseEntity allEvents() {
        List<EventData> eventDataList = eventDataService.getAllEvents();
        StringBuilder sb = new StringBuilder();
        eventDataList.forEach(e -> sb.append(e).append(System.lineSeparator()));

        return ResponseBuilder
                .status(OK).put(MESSAGE, sb.toString())
                .build();
    }

    @GetMapping("config")
    public ResponseEntity getConfig() {
        SimulatorConfig configToGet = simulatorService.getConfiguration();
        return buildResponse(OK, ImmutableMap.of("simulatorConfig", configToGet));
    }

    @PutMapping("config")
    public ResponseEntity updateConfig(@Valid @RequestBody SimulatorConfig newConfig) {
        SimulatorConfig updatedConfig = simulatorService.updateConfiguration(newConfig);
        return buildResponse(OK, ImmutableMap.of("simulatorConfig", updatedConfig));
    }

    @PostMapping("cancel/{jobName}")
    public ResponseEntity cancelEvent(@PathVariable String jobName) throws SchedulerException {
        LOGGER.info(ENTRY, "Cancel called on {}.", jobName);
        boolean isCancelled = simulatorService.cancelEvent(jobName);
        return createCancelEventResponse(isCancelled);
    }

    @PostMapping("cancel")
    public ResponseEntity cancelAllEvent() throws SchedulerException {
        LOGGER.info(ENTRY, "Cancel called on all jobs");
        boolean isCancelled = simulatorService.cancelAllEvents();
        return createCancelEventResponse(isCancelled);
    }

    @PostMapping("event")
    public ResponseEntity sendEventDirectly(@RequestHeader HttpHeaders headers, @Valid @RequestBody FullEvent event)
            throws IOException, GeneralSecurityException{
        logContextHeaders(headers, "/simulator/event");
        LOGGER.info(ENTRY, "Trying to send one-time event directly to VES Collector");
        simulatorService.triggerOneTimeEvent(event);
        return buildResponse(ACCEPTED, ImmutableMap.of(MESSAGE, "One-time direct event sent successfully"));
    }

    private ResponseEntity processRequest(SimulatorRequest triggerEventRequest)
            throws IOException, SchedulerException, GeneralSecurityException {

        String jobName = simulatorService.triggerEvent(triggerEventRequest);
        MDC.put(RESPONSE_CODE, OK.toString());
        return buildResponse(OK, ImmutableMap.of(MESSAGE, "Request started", "jobName", jobName));
    }

    private ResponseEntity buildResponse(HttpStatus endStatus, Map<String, Object> parameters) {
        ResponseBuilder builder = ResponseBuilder
                .status(endStatus)
                .put(TIMESTAMP, DateUtil.getTimestamp(responseDateFormat));
        parameters.forEach(builder::put);
        return builder.build();
    }

    private void logContextHeaders(HttpHeaders headers, String serviceName) {
        MDC.put(REQUEST_ID, headers.getFirst(X_ONAP_REQUEST_ID));
        MDC.put(INVOCATION_ID, headers.getFirst(X_INVOCATION_ID));
        MDC.put(INSTANCE_UUID, UUID.randomUUID().toString());
        MDC.put(SERVICE_NAME, serviceName);
    }

    private ResponseEntity createCancelEventResponse(boolean isCancelled) {
        if (isCancelled) {
            return buildResponse(OK, ImmutableMap.of(MESSAGE, "Event(s) was cancelled"));
        } else {
            return buildResponse(NOT_FOUND, ImmutableMap.of(MESSAGE, "Simulator was not able to cancel event(s)"));
        }
    }
}
