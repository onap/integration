/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
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

package org.onap.pnfsimulator.simulator.client;

import static org.onap.pnfsimulator.logging.MDCVariables.REQUEST_ID;
import static org.onap.pnfsimulator.logging.MDCVariables.X_INVOCATION_ID;
import static org.onap.pnfsimulator.logging.MDCVariables.X_ONAP_REQUEST_ID;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.UUID;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.util.EntityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.slf4j.Marker;
import org.slf4j.MarkerFactory;

public class HttpClientAdapterImpl implements HttpClientAdapter {

    private static final Logger LOGGER = LoggerFactory.getLogger(HttpClientAdapterImpl.class);
    private static final String CONTENT_TYPE = "Content-Type";
    private static final String APPLICATION_JSON = "application/json";
    private final Marker INVOKE = MarkerFactory.getMarker("INVOKE");
    private static final RequestConfig CONFIG = RequestConfig.custom()
        .setConnectTimeout(1000)
        .setConnectionRequestTimeout(1000)
        .setSocketTimeout(1000)
        .build();

    private HttpClient client;

    public HttpClientAdapterImpl() {
        this.client = HttpClientBuilder
            .create()
            .setDefaultRequestConfig(CONFIG)
            .build();
    }

    @Override
    public void send(String content, String url) {
        try {
            HttpPost request = createRequest(content, url);
            HttpResponse response = client.execute(request);
            EntityUtils.consumeQuietly(response.getEntity());
            LOGGER.info(INVOKE, "Message sent, ves response code: {}", response.getStatusLine());
        } catch (IOException e) {
            LOGGER.warn("Error sending message to ves: {}", e.getMessage());
        }
    }

    HttpClientAdapterImpl(HttpClient client) {
        this.client = client;
    }

    private HttpPost createRequest(String content, String url) throws UnsupportedEncodingException {
        HttpPost request = new HttpPost(url);
        StringEntity stringEntity = new StringEntity(content);
        request.addHeader(CONTENT_TYPE, APPLICATION_JSON);
        request.addHeader(X_ONAP_REQUEST_ID, MDC.get(REQUEST_ID));
        request.addHeader(X_INVOCATION_ID, UUID.randomUUID().toString());
        request.setEntity(stringEntity);
        return request;
    }
}