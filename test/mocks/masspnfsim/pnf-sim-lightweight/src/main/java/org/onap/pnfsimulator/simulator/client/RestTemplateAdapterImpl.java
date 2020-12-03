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
import static org.onap.pnfsimulator.logging.MDCVariables.AUTHORIZATION;

import org.springframework.web.client.ResourceAccessException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.X509Certificate;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import org.apache.http.conn.ssl.NoopHostnameVerifier;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

import org.springframework.http.HttpEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpHeaders;

import java.util.UUID;
import org.springframework.web.client.HttpClientErrorException;
import org.apache.http.client.config.RequestConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.slf4j.Marker;
import org.slf4j.MarkerFactory;

public class RestTemplateAdapterImpl implements RestTemplateAdapter {

    private static final Logger LOGGER = LoggerFactory.getLogger(RestTemplateAdapterImpl.class);
    private static final String CONTENT_TYPE = "Content-Type";
    private static final String APPLICATION_JSON = "application/json";
    private final Marker INVOKE = MarkerFactory.getMarker("INVOKE");
    private static final RequestConfig CONFIG = RequestConfig.custom()
        .setConnectTimeout(1000)
        .setConnectionRequestTimeout(1000)
        .setSocketTimeout(1000)
        .build();

    private RestTemplate restTemplate;

    public RestTemplateAdapterImpl() {
        try {
        this.restTemplate = createRestTemplate();
        } catch (KeyStoreException | NoSuchAlgorithmException | KeyManagementException ex) {
            LOGGER.warn("Error while creating a RestTemplate object: {}", ex.getMessage());
        }
    }

    RestTemplateAdapterImpl(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @Override
    public void send(String content, String url) {
        try {
            HttpEntity<String> entity = createPostEntity(content);
            ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);
            LOGGER.info(INVOKE, "Message sent, ves response code: {}", response.getStatusCode());
        } catch (HttpClientErrorException codeEx) {
            LOGGER.warn("Response body: ", codeEx.getResponseBodyAsString());
            LOGGER.warn("Error sending message to ves: {}", codeEx.getMessage());
            LOGGER.warn("URL: {}", url);
        } catch (ResourceAccessException ioEx) {
            LOGGER.warn("The URL cannot be reached: {}", ioEx.getMessage());
            LOGGER.warn("URL: {}", url);
        }
    }

    private CloseableHttpClient createClient()
    throws KeyStoreException, NoSuchAlgorithmException, KeyManagementException {

        TrustManager[] trustAllCerts = new TrustManager[] {
            new X509TrustManager() {

                public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                    return new X509Certificate[0];
                }

                public void checkClientTrusted(
                    java.security.cert.X509Certificate[] certs,
                    String authType) {}

                public void checkServerTrusted(
                    java.security.cert.X509Certificate[] certs,
                    String authType) {}
            }
        };

        SSLContext sslContext = SSLContext.getInstance("TLS");
        sslContext.init(
            null,
            trustAllCerts,
            new java.security.SecureRandom()
        );

        CloseableHttpClient httpClient = HttpClients
            .custom()
            .setSSLContext(sslContext)
            .setSSLHostnameVerifier(NoopHostnameVerifier.INSTANCE)
            .build();

        return httpClient;
    }

    private RestTemplate createRestTemplate()
    throws KeyStoreException, NoSuchAlgorithmException, KeyManagementException {

        CloseableHttpClient client = createClient();
        HttpComponentsClientHttpRequestFactory requestFactory = new HttpComponentsClientHttpRequestFactory();
        requestFactory.setHttpClient(client);

        return new RestTemplate(requestFactory);

    }

    private HttpEntity createPostEntity(String content) {

        HttpHeaders headers = new HttpHeaders();
        headers.set(CONTENT_TYPE, APPLICATION_JSON);
        headers.set(AUTHORIZATION, MDC.get(AUTHORIZATION));
        headers.set(X_ONAP_REQUEST_ID, MDC.get(REQUEST_ID));
        headers.set(X_INVOCATION_ID, UUID.randomUUID().toString());

        return new HttpEntity<>(content, headers);

    }
}