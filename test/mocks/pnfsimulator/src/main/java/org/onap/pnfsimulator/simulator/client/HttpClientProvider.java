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

package org.onap.pnfsimulator.simulator.client;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class HttpClientProvider {

    private static final Logger logger = LogManager.getLogger(HttpClientProvider.class);
    private static final String CONTENT_TYPE = "Content-Type";
    private static final String APPLICATION_JSON = "application/json";

    private HttpClient client;
    private String url;

    public HttpClientProvider(String url) {

        RequestConfig config = RequestConfig.custom()
            .setConnectTimeout(1000)
            .setConnectionRequestTimeout(1000)
            .setSocketTimeout(1000)
            .build();

        this.client = HttpClientBuilder
            .create()
            .setDefaultRequestConfig(config)
            .build();

        this.url = url;
    }

    public void sendMsg(String content) {
        try {
            HttpPost request = createRequest(content);
            HttpResponse response = client.execute(request);
            logger.info("MESSAGE SENT, VES RESPONSE CODE: {}", response.getStatusLine());
        } catch (IOException e) {
            logger.info("ERROR SENDING MESSAGE TO VES: {}", e.getMessage());
        }
    }

    private HttpPost createRequest(String content) throws UnsupportedEncodingException {
        StringEntity stringEntity = new StringEntity(content);
        HttpPost request = new HttpPost(url);
        request.addHeader(CONTENT_TYPE, APPLICATION_JSON);
        request.setEntity(stringEntity);
        return request;
    }
}
