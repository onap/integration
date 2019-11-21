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

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.conn.socket.PlainConnectionSocketFactory;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.onap.pnfsimulator.simulator.client.utils.ssl.SSLAuthenticationHelper;

import java.io.IOException;
import java.net.MalformedURLException;
import java.security.GeneralSecurityException;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

class HttpClientAdapterImplTest {

    private static final String HTTPS_URL = "https://0.0.0.0:8443/";
    private static final String HTTP_URL = "http://0.0.0.0:8000/";

    private HttpClient httpClient;
    private HttpResponse httpResponse;

    @BeforeEach
    void setup() {
        httpClient = mock(HttpClient.class);
        httpResponse = mock(HttpResponse.class);
    }

    @Test
    void sendShouldSuccessfullySendRequestGivenValidUrl() throws IOException {
        assertAdapterSentRequest("http://valid-url:8080");
    }

    @Test
    void sendShouldSuccessfullySendRequestGivenValidUrlUsingHTTPS() throws IOException {
        assertAdapterSentRequest("https://valid-url:8443");
    }

    @Test
    void shouldThrowExceptionWhenMalformedVesUrlPassed(){
        assertThrows(MalformedURLException.class, () -> new HttpClientAdapterImpl("http://blablabla:VES-PORT", new SSLAuthenticationHelper()));
    }
    @Test
    void shouldCreateAdapterWithClientNotSupportingSSLConnection() throws IOException, GeneralSecurityException {
        HttpClientAdapter adapterWithHttps = new HttpClientAdapterImpl(HTTPS_URL, new SSLAuthenticationHelper());
        try {
            adapterWithHttps.send("sample");
        } catch (Exception actualException) {
            assertThat(actualException).hasStackTraceContaining(SSLConnectionSocketFactory.class.toString());
        }
    }

    @Test
    void shouldCreateAdapterWithClientSupportingPlainConnectionOnly() throws IOException, GeneralSecurityException {
        HttpClientAdapter adapterWithHttps = new HttpClientAdapterImpl(HTTP_URL, new SSLAuthenticationHelper());
        try {
            adapterWithHttps.send("sample");
        } catch (Exception actualException) {
            assertThat(actualException).hasStackTraceContaining(PlainConnectionSocketFactory.class.toString());
        }
    }

    private void assertAdapterSentRequest(String targetUrl) throws IOException {
        HttpClientAdapter adapter = new HttpClientAdapterImpl(httpClient, targetUrl);
        doReturn(httpResponse).when(httpClient).execute(any());

        adapter.send("test-msg");

        verify(httpClient).execute(any());
        verify(httpResponse).getStatusLine();
    }
}
