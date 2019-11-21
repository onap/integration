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

package org.onap.pnfsimulator.simulator.client;

import static org.onap.pnfsimulator.logging.MDCVariables.REQUEST_ID;
import static org.onap.pnfsimulator.logging.MDCVariables.X_INVOCATION_ID;
import static org.onap.pnfsimulator.logging.MDCVariables.X_ONAP_REQUEST_ID;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;
import java.util.UUID;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.util.EntityUtils;
import org.onap.pnfsimulator.simulator.client.utils.ssl.SSLAuthenticationHelper;
import org.onap.pnfsimulator.simulator.client.utils.ssl.SslSupportLevel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.slf4j.Marker;
import org.slf4j.MarkerFactory;

public class HttpClientAdapterImpl implements HttpClientAdapter {

    private static final int CONNECTION_TIMEOUT = 1000;
    private static final Logger LOGGER = LoggerFactory.getLogger(HttpClientAdapterImpl.class);
    private static final String CONTENT_TYPE = "Content-Type";
    private static final String APPLICATION_JSON = "application/json";
    private static final RequestConfig CONFIG = RequestConfig.custom()
            .setConnectTimeout(CONNECTION_TIMEOUT)
            .setConnectionRequestTimeout(CONNECTION_TIMEOUT)
            .setSocketTimeout(CONNECTION_TIMEOUT)
            .build();
    private static final Marker INVOKE = MarkerFactory.getMarker("INVOKE");
    private  SslSupportLevel sslSupportLevel;
    private HttpClient client;
    private final String targetUrl;

    public HttpClientAdapterImpl(String targetUrl, SSLAuthenticationHelper sslAuthenticationHelper)
            throws IOException, GeneralSecurityException {
        this.sslSupportLevel = sslAuthenticationHelper.isClientCertificateEnabled() ?
                SslSupportLevel.CLIENT_CERT_AUTH : SslSupportLevel.getSupportLevelBasedOnProtocol(targetUrl);
        this.client = sslSupportLevel.getClient(CONFIG, sslAuthenticationHelper);
        this.targetUrl = targetUrl;
    }

    HttpClientAdapterImpl(HttpClient client, String targetUrl) {
        this.client = client;
        this.targetUrl = targetUrl;
    }

    @Override
    public void send(String content) {
        try {
            HttpPost request = createRequest(content);
            HttpResponse response = client.execute(request);

            //response has to be fully consumed otherwise apache won't release connection
            EntityUtils.consumeQuietly(response.getEntity());
            LOGGER.info(INVOKE, "Message sent, ves response code: {}", response.getStatusLine());
        } catch (IOException e) {
            LOGGER.warn("Error sending message to ves: " + e.getMessage(), e.getCause());
        }
    }

    public SslSupportLevel getSslSupportLevel(){
        return sslSupportLevel;
    }

    private HttpPost createRequest(String content) throws UnsupportedEncodingException {
        HttpPost request = new HttpPost(this.targetUrl);
        StringEntity stringEntity = new StringEntity(content);
        request.addHeader(CONTENT_TYPE, APPLICATION_JSON);
        request.addHeader(X_ONAP_REQUEST_ID, MDC.get(REQUEST_ID));
        request.addHeader(X_INVOCATION_ID, UUID.randomUUID().toString());
        request.setEntity(stringEntity);
        return request;
    }


}
