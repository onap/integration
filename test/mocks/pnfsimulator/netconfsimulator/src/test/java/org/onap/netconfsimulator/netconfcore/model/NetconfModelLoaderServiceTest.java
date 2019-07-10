/*-
 * ============LICENSE_START=======================================================
 * Simulator
 * ================================================================================
 * Copyright (C) 2019 Nokia. All rights reserved.
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

package org.onap.netconfsimulator.netconfcore.model;


import static org.assertj.core.api.AssertionsForInterfaceTypes.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpRequestBase;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.web.multipart.MultipartFile;

class NetconfModelLoaderServiceTest {

    @Mock
    private HttpClient httpClient;

    private NetconfModelLoaderService modelLoaderService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.initMocks(this);
        modelLoaderService = new NetconfModelLoaderService(httpClient);
    }


    @Test
    void shouldSendMultipartToServer() throws IOException {
        //given
        String loadModelAddress = modelLoaderService.getBackendAddress();
        makeMockClientReturnStatusOk(httpClient, HttpPost.class);
        ArgumentCaptor<HttpPost> postArgumentCaptor = ArgumentCaptor.forClass(HttpPost.class);
        MultipartFile yangMmodel = mock(MultipartFile.class);
        MultipartFile initialConfig = mock(MultipartFile.class);
        String moduleName = "moduleName";
        when(yangMmodel.getInputStream()).thenReturn(getEmptyImputStream());
        when(initialConfig.getInputStream()).thenReturn(getEmptyImputStream());

        //when
        LoadModelResponse response = modelLoaderService.loadYangModel(yangMmodel, initialConfig, moduleName);

        //then
        verify(httpClient).execute(postArgumentCaptor.capture());
        HttpPost sentPost = postArgumentCaptor.getValue();
        assertThat(response.getStatusCode()).isEqualTo(200);
        assertThat(response.getMessage()).isEqualTo("");
        assertThat(sentPost.getURI().toString()).isEqualTo(loadModelAddress);
        assertThat(sentPost.getEntity().getContentType().getElements()[0].getName()).isEqualTo("multipart/form-data");
    }

    @Test
    void shouldSendDeleteRequestToServer() throws IOException {
        //given
        String yangModelName = "sampleModel";
        String deleteModelAddress = modelLoaderService.getDeleteAddress(yangModelName);
        makeMockClientReturnStatusOk(httpClient, HttpDelete.class);
        ArgumentCaptor<HttpDelete> deleteArgumentCaptor = ArgumentCaptor.forClass(HttpDelete.class);

        //when
        LoadModelResponse response = modelLoaderService.deleteYangModel(yangModelName);

        //then
        verify(httpClient).execute(deleteArgumentCaptor.capture());
        HttpDelete sendDelete = deleteArgumentCaptor.getValue();
        assertThat(response.getStatusCode()).isEqualTo(200);
        assertThat(response.getMessage()).isEqualTo("");
        assertThat(sendDelete.getURI().toString()).isEqualTo(deleteModelAddress);
    }

    private void makeMockClientReturnStatusOk(HttpClient client,
            Class<? extends HttpRequestBase> httpMethodClass) throws IOException {
        HttpResponse httpResponse = mock(HttpResponse.class);
        StatusLine mockStatus = mock(StatusLine.class);
        HttpEntity mockEntity = mock(HttpEntity.class);

        when(client.execute(any(httpMethodClass))).thenReturn(httpResponse);
        when(httpResponse.getStatusLine()).thenReturn(mockStatus);
        when(mockStatus.getStatusCode()).thenReturn(200);
        when(httpResponse.getEntity()).thenReturn(mockEntity);
        when(mockEntity.getContent()).thenReturn(getEmptyImputStream());
    }

    private InputStream getEmptyImputStream() {
        return new ByteArrayInputStream("".getBytes());
    }

}
