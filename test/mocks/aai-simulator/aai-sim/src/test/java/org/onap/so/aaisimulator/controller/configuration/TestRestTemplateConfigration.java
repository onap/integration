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
package org.onap.aaisimulator.controller.configuration;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLSession;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.conn.ssl.TrustStrategy;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.ssl.SSLContexts;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@Profile("test")
@Configuration
public class TestRestTemplateConfigration {

    private static final Logger LOGGER = LoggerFactory.getLogger(TestRestTemplateConfigration.class);

    @Bean
    public TestRestTemplate testRestTemplate() throws Exception {
        final TestRestTemplate testRestTemplate = new TestRestTemplate();
        ((HttpComponentsClientHttpRequestFactory) testRestTemplate.getRestTemplate().getRequestFactory())
                .setHttpClient(httpClient());
        return testRestTemplate;

    }

    @Bean
    public RestTemplate restTemplate() throws Exception {
        final RestTemplate restTemplate = new RestTemplate();
        restTemplate.setRequestFactory(new HttpComponentsClientHttpRequestFactory(httpClient()));
        return restTemplate;
    }

    private CloseableHttpClient httpClient() throws Exception {
        final TrustStrategy acceptingTrustStrategy = (cert, authType) -> true;

        final SSLConnectionSocketFactory csf = new SSLConnectionSocketFactory(
                SSLContexts.custom().loadTrustMaterial(null, acceptingTrustStrategy).build(), new HostnameVerifier() {
                    @Override
                    public boolean verify(final String hostname, final SSLSession session) {
                        LOGGER.warn("Skiping hostname verification ... ");
                        return true;
                    }

                });

        return HttpClients.custom().setSSLSocketFactory(csf).build();
    }

}
