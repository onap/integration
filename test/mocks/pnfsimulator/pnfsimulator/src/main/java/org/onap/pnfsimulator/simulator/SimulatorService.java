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

package org.onap.pnfsimulator.simulator;

import com.google.common.base.Strings;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.net.MalformedURLException;
import java.security.GeneralSecurityException;
import java.util.Optional;
import org.onap.pnfsimulator.event.EventData;
import org.onap.pnfsimulator.event.EventDataService;
import org.onap.pnfsimulator.rest.model.FullEvent;
import org.onap.pnfsimulator.rest.model.SimulatorParams;
import org.onap.pnfsimulator.rest.model.SimulatorRequest;
import org.onap.pnfsimulator.simulator.client.HttpClientAdapter;
import org.onap.pnfsimulator.simulator.client.HttpClientAdapterImpl;
import org.onap.pnfsimulator.simulator.client.utils.ssl.SSLAuthenticationHelper;
import org.onap.pnfsimulator.simulator.scheduler.EventScheduler;
import org.onap.pnfsimulator.simulatorconfig.SimulatorConfig;
import org.onap.pnfsimulator.simulatorconfig.SimulatorConfigService;
import org.quartz.SchedulerException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class SimulatorService {

    private final TemplatePatcher templatePatcher;
    private final TemplateReader templateReader;
    private final EventDataService eventDataService;
    private final EventScheduler eventScheduler;
    private final SSLAuthenticationHelper sslAuthenticationHelper;
    private SimulatorConfigService simulatorConfigService;
    private static final JsonObject EMPTY_JSON_OBJECT = new JsonObject();

    @Autowired
    public SimulatorService(TemplatePatcher templatePatcher, TemplateReader templateReader,
                            EventScheduler eventScheduler, EventDataService eventDataService,
                            SimulatorConfigService simulatorConfigService, SSLAuthenticationHelper sslAuthenticationHelper) {
        this.templatePatcher = templatePatcher;
        this.templateReader = templateReader;
        this.eventDataService = eventDataService;
        this.eventScheduler = eventScheduler;
        this.simulatorConfigService = simulatorConfigService;
        this.sslAuthenticationHelper = sslAuthenticationHelper;
    }

    public String triggerEvent(SimulatorRequest simulatorRequest) throws IOException, SchedulerException, GeneralSecurityException {
        String templateName = simulatorRequest.getTemplateName();
        SimulatorParams simulatorParams = simulatorRequest.getSimulatorParams();
        JsonObject template = templateReader.readTemplate(templateName);
        JsonObject input = Optional.ofNullable(simulatorRequest.getPatch()).orElse(new JsonObject());
        JsonObject patchedJson = templatePatcher
                .mergeTemplateWithPatch(template, input);
        JsonObject keywords = new JsonObject();

        EventData eventData = eventDataService.persistEventData(template, patchedJson, input, keywords);

        String targetVesUrl = getDefaultUrlIfNotProvided(simulatorParams.getVesServerUrl());
        return eventScheduler
                .scheduleEvent(targetVesUrl, Optional.ofNullable(simulatorParams.getRepeatInterval()).orElse(1),
                        Optional.ofNullable(simulatorParams.getRepeatCount()).orElse(1), simulatorRequest.getTemplateName(),
                        eventData.getId(),
                patchedJson);
    }

    public void triggerOneTimeEvent(FullEvent event) throws IOException, GeneralSecurityException {
        KeywordsHandler keywordsHandler = new KeywordsHandler(new KeywordsExtractor(), id -> 1);
        JsonObject withKeywordsSubstituted = keywordsHandler.substituteKeywords(event.getEvent(), "").getAsJsonObject();

        HttpClientAdapter client = createHttpClientAdapter(event.getVesServerUrl());
        eventDataService.persistEventData(EMPTY_JSON_OBJECT, withKeywordsSubstituted, event.getEvent(), EMPTY_JSON_OBJECT);

        client.send(withKeywordsSubstituted.toString());
    }

    public SimulatorConfig getConfiguration() {
        return simulatorConfigService.getConfiguration();
    }

    public SimulatorConfig updateConfiguration(SimulatorConfig newConfig) {
        return simulatorConfigService.updateConfiguration(newConfig);
    }

    public boolean cancelAllEvents() throws SchedulerException {
        return eventScheduler.cancelAllEvents();
    }

    public boolean cancelEvent(String jobName) throws SchedulerException {
        return eventScheduler.cancelEvent(jobName);
    }

    HttpClientAdapter createHttpClientAdapter(String vesServerUrl) throws IOException, GeneralSecurityException {
        String targetVesUrl = getDefaultUrlIfNotProvided(vesServerUrl);
        return new HttpClientAdapterImpl(targetVesUrl, sslAuthenticationHelper);
    }

    private String getDefaultUrlIfNotProvided(String vesUrlSimulatorParam) {
        return Strings.isNullOrEmpty(vesUrlSimulatorParam)
                ? simulatorConfigService.getConfiguration().getVesServerUrl().toString() : vesUrlSimulatorParam;
    }
}
