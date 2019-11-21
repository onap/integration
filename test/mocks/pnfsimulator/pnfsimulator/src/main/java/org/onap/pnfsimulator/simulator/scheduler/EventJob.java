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

package org.onap.pnfsimulator.simulator.scheduler;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import org.onap.pnfsimulator.simulator.KeywordsHandler;
import org.onap.pnfsimulator.simulator.client.HttpClientAdapter;
import org.onap.pnfsimulator.simulator.client.HttpClientAdapterImpl;
import org.onap.pnfsimulator.simulator.client.utils.ssl.SSLAuthenticationHelper;
import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.net.MalformedURLException;
import java.security.GeneralSecurityException;
import java.util.Optional;

public class EventJob implements Job {

    private static final Logger LOGGER = LoggerFactory.getLogger(EventJob.class);

    static final String TEMPLATE_NAME = "TEMPLATE_NAME";
    static final String VES_URL = "VES_URL";
    static final String BODY = "BODY";
    static final String CLIENT_ADAPTER = "CLIENT_ADAPTER";
    static final String KEYWORDS_HANDLER = "KEYWORDS_HANDLER";
    static final String EVENT_ID = "EVENT_ID";

    @Override
    public void execute(JobExecutionContext jobExecutionContext) {
        JobDataMap jobDataMap = jobExecutionContext.getJobDetail().getJobDataMap();
        String templateName = jobDataMap.getString(TEMPLATE_NAME);
        String vesUrl = jobDataMap.getString(VES_URL);
        JsonObject body = (JsonObject) jobDataMap.get(BODY);
        String id = jobDataMap.getString(EVENT_ID);
        Optional<HttpClientAdapter> httpClientAdapter = getHttpClientAdapter(jobDataMap, vesUrl);

        if (httpClientAdapter.isPresent()) {
            KeywordsHandler keywordsHandler = (KeywordsHandler) jobDataMap.get(KEYWORDS_HANDLER);
            JsonElement processedBody = keywordsHandler.substituteKeywords(body, id);
            String processedBodyString = processedBody.toString();
            String jobKey = jobExecutionContext.getJobDetail().getKey().toString();

            logEventDetails(templateName, vesUrl, body.toString(), jobKey);
            httpClientAdapter.get().send(processedBodyString);
        } else {
            LOGGER.error("Could not send event as client is not available");
        }
    }
    private Optional<HttpClientAdapter> getHttpClientAdapter(JobDataMap jobDataMap, String vesUrl) {
        HttpClientAdapter adapter = null;
        try {
            adapter = (HttpClientAdapter) (jobDataMap.containsKey(CLIENT_ADAPTER) ? jobDataMap.get(CLIENT_ADAPTER) :
                     new HttpClientAdapterImpl(vesUrl, new SSLAuthenticationHelper()));
        } catch (MalformedURLException e) {
            LOGGER.error("Invalid format of vesServerUr: {}", vesUrl);
        } catch (IOException | GeneralSecurityException e){
            LOGGER.error("Invalid configuration of client certificate");
        }
        return Optional.ofNullable(adapter);
    }

    private void logEventDetails(String templateName, String vesUrl, String body, String jobKey) {
        LOGGER.info(String.format("Job %s:Sending event to %s from template %s",
                jobKey, vesUrl, templateName));
        if (LOGGER.isDebugEnabled()) {
            LOGGER.debug(String.format("Job %s: Request body %s", jobKey, body));
        }
    }

}
