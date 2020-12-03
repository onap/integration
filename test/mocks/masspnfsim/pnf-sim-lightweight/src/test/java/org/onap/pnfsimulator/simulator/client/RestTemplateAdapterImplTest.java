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

import org.mockito.Mock;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.notNull;
import static org.mockito.Mockito.verify;
import static org.mockito.MockitoAnnotations.initMocks;

import org.springframework.web.client.HttpClientErrorException;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class RestTemplateAdapterImplTest {

    private RestTemplateAdapter adapter;

    @Mock
    private RestTemplate restTemplate;
    @Mock
    ResponseEntity<String> response;

    @BeforeEach
    void setup() {
        initMocks(this);
        adapter = new RestTemplateAdapterImpl(restTemplate);
    }

    @Test
    void send_should_successfully_send_request_given_valid_http_url()
    throws HttpClientErrorException {

        String content = "test-msg";
        String urlHttp = "http://valid-url";

        when(
            restTemplate.postForEntity(
                (String) notNull(),
                (HttpEntity) notNull(),
                eq(String.class)
            )
        ).thenReturn(response);

        adapter.send(content, urlHttp);

        verify(
            restTemplate, times(1)).postForEntity(
            (String) notNull(),
            (HttpEntity) notNull(),
            eq(String.class)
        );
        verify(response).getStatusCode();
    }

    @Test
    void send_should_successfully_send_request_given_valid_https_url()
    throws HttpClientErrorException {

        String content = "test-msg";
        String urlHttps = "https://valid-url";

        when(
            restTemplate.postForEntity(
                (String) notNull(),
                (HttpEntity) notNull(),
                eq(String.class)
            )
        ).thenReturn(response);

        adapter.send(content, urlHttps);

        verify(
            restTemplate, times(1)).postForEntity(
            (String) notNull(),
            (HttpEntity) notNull(),
            eq(String.class)
        );
        verify(response).getStatusCode();
    }

    @Test
    void send_should_not_send_request_given_invalid_url()
    throws HttpClientErrorException {

        String content = "test-msg";
        String url = "http://invalid-url";

        doThrow(
            new HttpClientErrorException(HttpStatus.BAD_REQUEST)).when(
            restTemplate).postForEntity(
            (String) notNull(),
            (HttpEntity) notNull(),
            eq(String.class)
        );

        adapter.send(content, url);

        verify(
            restTemplate, times(1)).postForEntity(
            (String) notNull(),
            (HttpEntity) notNull(),
            eq(String.class)
        );
        verify(response, never()).getStatusCode();
    }
}
