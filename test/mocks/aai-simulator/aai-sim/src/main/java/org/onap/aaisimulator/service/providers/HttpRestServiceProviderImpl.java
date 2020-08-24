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
package org.onap.aaisimulator.service.providers;

import java.util.Optional;
import org.onap.aaisimulator.exception.InvalidRestRequestException;
import org.onap.aaisimulator.exception.RestProcessingException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Service
public class HttpRestServiceProviderImpl implements HttpRestServiceProvider {
    private static final Logger LOGGER = LoggerFactory.getLogger(HttpRestServiceProviderImpl.class);

    private final RestTemplate restTemplate;

    @Autowired
    public HttpRestServiceProviderImpl(final RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @Override
    public <T> ResponseEntity<T> invokeHttpPut(final HttpEntity<Object> httpEntity, final String url,
            final Class<T> clazz) {

        final HttpMethod httpMethod = HttpMethod.PUT;
        LOGGER.trace("Will invoke HTTP {} using URL: {}", httpMethod, url);
        try {
            return restTemplate.exchange(url, httpMethod, httpEntity, clazz);

        } catch (final HttpClientErrorException httpClientErrorException) {
            final String message = "Unable to invoke HTTP " + httpMethod + " using url: " + url + ", Response: "
                    + httpClientErrorException.getRawStatusCode();
            LOGGER.error(message, httpClientErrorException);
            final int rawStatusCode = httpClientErrorException.getRawStatusCode();
            if (rawStatusCode == HttpStatus.BAD_REQUEST.value() || rawStatusCode == HttpStatus.NOT_FOUND.value()) {
                throw new InvalidRestRequestException("No result found for given url: " + url);
            }
            throw new RestProcessingException("Unable to invoke HTTP " + httpMethod + " using URL: " + url);

        } catch (final RestClientException restClientException) {
            LOGGER.error("Unable to invoke HTTP POST using url: {}", url, restClientException);
            throw new RestProcessingException("Unable to invoke HTTP " + httpMethod + " using URL: " + url,
                    restClientException);
        }
    }

    @Override
    public <T> Optional<T> put(final HttpHeaders headers, final Object object, final String url, final Class<T> clazz) {
        final HttpEntity<Object> httpEntity = new HttpEntity<Object>(object, headers);
        final ResponseEntity<T> response = invokeHttpPut(httpEntity, url, clazz);

        if (!response.getStatusCode().equals(HttpStatus.OK) && !response.getStatusCode().equals(HttpStatus.CREATED)
                && !response.getStatusCode().equals(HttpStatus.ACCEPTED)) {
            final String message = "Unable to invoke HTTP " + HttpMethod.PUT + " using URL: " + url
                    + ", Response Code: " + response.getStatusCode();
            LOGGER.error(message);
            return Optional.empty();
        }

        if (response.hasBody()) {
            return Optional.of(response.getBody());
        }
        LOGGER.error("Received response without body status code: {}", response.getStatusCode());
        return Optional.empty();
    }
}
