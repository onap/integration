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

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.MockitoAnnotations.initMocks;

import java.io.IOException;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;

class HttpClientAdapterImplTest {

    private HttpClientAdapter adapter;

    @Mock
    private HttpClient httpClient;
    @Mock
    private HttpResponse httpResponse;

    @BeforeEach
    void setup() {
        initMocks(this);
        adapter = new HttpClientAdapterImpl(httpClient);
    }

    @Test
    void send_should_successfully_send_request_given_valid_url() throws IOException {
        doReturn(httpResponse).when(httpClient).execute(any());

        adapter.send("test-msg", "http://valid-url");

        verify(httpClient).execute(any());
        verify(httpResponse).getStatusLine();
    }

    @Test
    void send_should_not_send_request_given_invalid_url() throws IOException {
        doThrow(new IOException("test")).when(httpClient).execute(any());

        adapter.send("test-msg", "http://invalid-url");

        verify(httpClient).execute(any());
        verify(httpResponse, never()).getStatusLine();
    }
}
