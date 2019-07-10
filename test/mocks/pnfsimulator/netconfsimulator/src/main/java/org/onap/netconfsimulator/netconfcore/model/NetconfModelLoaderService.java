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

import java.io.IOException;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.util.EntityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class NetconfModelLoaderService {

    private static final Logger LOGGER = LoggerFactory.getLogger(NetconfModelLoaderService.class);

    @Value("${netconf.address}")
    private String netconfIp;

    @Value("${netconf.model-loader.port}")
    private String modelLoaderPort;

    private final HttpClient httpClient;

    @Autowired
    public NetconfModelLoaderService(HttpClient httpClient) {
        this.httpClient = httpClient;
    }

    public LoadModelResponse deleteYangModel(String yangModelName) throws IOException {
        String uri = getDeleteAddress(yangModelName);
        HttpDelete httpDelete = new HttpDelete(uri);
        HttpResponse httpResponse = httpClient.execute(httpDelete);
        return parseResponse(httpResponse);
    }

    public LoadModelResponse loadYangModel(MultipartFile yangModel, MultipartFile initialConfig, String moduleName)
        throws IOException {
        HttpPost httpPost = new HttpPost(getBackendAddress());
        HttpEntity httpEntity = MultipartEntityBuilder.create()
            .addBinaryBody("yangModel", yangModel.getInputStream(), ContentType.MULTIPART_FORM_DATA,
                yangModel.getOriginalFilename())
            .addBinaryBody("initialConfig", initialConfig.getInputStream(), ContentType.MULTIPART_FORM_DATA,
                initialConfig.getOriginalFilename())
            .addTextBody("moduleName", moduleName)
            .build();
        httpPost.setEntity(httpEntity);
        HttpResponse response = httpClient.execute(httpPost);
        return parseResponse(response);
    }

    String getBackendAddress() {
        return String.format("http://%s:%s/model", netconfIp, modelLoaderPort);
    }

    String getDeleteAddress(String yangModelName) {
        return String.format("%s?yangModelName=%s", getBackendAddress(), yangModelName);
    }


    private LoadModelResponse parseResponse(HttpResponse response) throws IOException {
        int statusCode = response.getStatusLine().getStatusCode();
        String responseBody = EntityUtils.toString(response.getEntity());

        logResponse(statusCode, responseBody);
        return new LoadModelResponse(statusCode, responseBody);
    }

    private void logResponse(int statusCode, String responseBody) {
        if (statusCode >= HttpStatus.BAD_REQUEST.value()) {
            LOGGER.error(responseBody);
        } else {
            LOGGER.info(responseBody);
        }
    }
}
