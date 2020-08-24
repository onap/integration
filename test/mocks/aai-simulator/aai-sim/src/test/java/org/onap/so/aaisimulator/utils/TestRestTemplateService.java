/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2019 Nordix Foundation.
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
 *
 * SPDX-License-Identifier: Apache-2.0
 * ============LICENSE_END=========================================================
 */
package org.onap.aaisimulator.utils;

import org.onap.aaisimulator.model.UserCredentials;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */

@Service
public class TestRestTemplateService {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserCredentials userCredentials;


    public <T> ResponseEntity<T> invokeHttpGet(final String url, final Class<T> clazz) {
        return restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(getHttpHeaders()), clazz);
    }

    public <T> ResponseEntity<T> invokeHttpPut(final String url, final Object obj, final Class<T> clazz) {
        final HttpEntity<?> httpEntity = getHttpEntity(obj);
        return restTemplate.exchange(url, HttpMethod.PUT, httpEntity, clazz);
    }

    public <T> ResponseEntity<T> invokeHttpDelete(final String url, final Class<T> clazz) {
        final HttpEntity<?> request = new HttpEntity<>(getHttpHeaders());
        return restTemplate.exchange(url, HttpMethod.DELETE, request, clazz);
    }

    public <T> ResponseEntity<T> invokeHttpPost(final String url, final Object obj, final Class<T> clazz) {
        final HttpEntity<?> httpEntity = getHttpEntity(obj);
        return restTemplate.exchange(url, HttpMethod.POST, httpEntity, clazz);
    }

    public <T> ResponseEntity<T> invokeHttpPost(final HttpHeaders headers, final String url, final Object obj,
            final Class<T> clazz) {
        final HttpEntity<Object> entity = new HttpEntity<>(obj, headers);
        return restTemplate.exchange(url, HttpMethod.POST, entity, clazz);
    }

    private HttpEntity<?> getHttpEntity(final Object obj) {
        return new HttpEntity<>(obj, getHttpHeaders());
    }

    public HttpHeaders getHttpHeaders() {
        return TestUtils.getHttpHeaders(userCredentials.getUsers().iterator().next().getUsername());
    }

}
