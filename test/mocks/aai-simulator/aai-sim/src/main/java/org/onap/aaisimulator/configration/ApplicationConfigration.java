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
package org.onap.aaisimulator.configration;

import java.util.ArrayList;
import java.util.List;
import javax.net.ssl.SSLContext;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.ssl.SSLContextBuilder;
import org.onap.aaisimulator.utils.CacheName;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.jackson.Jackson2ObjectMapperBuilderCustomizer;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.cache.concurrent.ConcurrentMapCache;
import org.springframework.cache.support.SimpleCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.io.Resource;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;
import com.fasterxml.jackson.module.jaxb.JaxbAnnotationModule;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@Configuration
public class ApplicationConfigration {
    private static final Logger LOGGER = LoggerFactory.getLogger(ApplicationConfigration.class);


    @Bean
    public Jackson2ObjectMapperBuilderCustomizer jacksonCustomizer() {
        return (mapperBuilder) -> mapperBuilder.modulesToInstall(new JaxbAnnotationModule());
    }

    @Bean
    public CacheManager cacheManager() {
        final SimpleCacheManager manager = new SimpleCacheManager();

        final List<Cache> caches = new ArrayList<>();
        for (final CacheName cacheName : CacheName.values()) {
            caches.add(getCache(cacheName.getName()));
        }
        manager.setCaches(caches);
        return manager;
    }

    private Cache getCache(final String name) {
        LOGGER.info("Creating cache with name: {}", name);
        return new ConcurrentMapCache(name);
    }

    @Profile("!test")
    @Bean
    public RestTemplate restTemplate(@Value("${http.client.ssl.trust-store:#{null}}") final Resource trustStore,
            @Value("${http.client.ssl.trust-store-password:#{null}}") final String trustStorePassword)
            throws Exception {
        LOGGER.info("Setting up RestTemplate .... ");
        final RestTemplate restTemplate = new RestTemplate();

        final HttpComponentsClientHttpRequestFactory factory =
                new HttpComponentsClientHttpRequestFactory(httpClient(trustStore, trustStorePassword));

        restTemplate.setRequestFactory(factory);
        return restTemplate;
    }

    private CloseableHttpClient httpClient(final Resource trustStore, final String trustStorePassword)
            throws Exception {
        LOGGER.info("Creating SSLConnectionSocketFactory with custom SSLContext and HostnameVerifier ... ");
        return HttpClients.custom().setSSLSocketFactory(getSSLConnectionSocketFactory(trustStore, trustStorePassword))
                .build();
    }

    private SSLConnectionSocketFactory getSSLConnectionSocketFactory(final Resource trustStore,
            final String trustStorePassword) throws Exception {
        return new SSLConnectionSocketFactory(getSslContext(trustStore, trustStorePassword));
    }

    private SSLContext getSslContext(final Resource trustStore, final String trustStorePassword)
            throws Exception, Exception {
        return new SSLContextBuilder().loadTrustMaterial(trustStore.getURL(), trustStorePassword.toCharArray()).build();
    }

}
