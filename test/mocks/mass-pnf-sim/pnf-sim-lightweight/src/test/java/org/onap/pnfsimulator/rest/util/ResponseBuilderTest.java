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

package org.onap.pnfsimulator.rest.util;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

public class ResponseBuilderTest {


    private static final HttpStatus SAMPLE_STATUS = HttpStatus.OK;

    @Test
    void response_should_have_empty_body_when_built_immediately() {
        ResponseEntity responseEntity = ResponseBuilder.status(SAMPLE_STATUS).build();

        assertAll(
            () -> assertEquals(responseEntity.getStatusCode(), SAMPLE_STATUS),
            () -> assertNull(responseEntity.getBody())
        );
    }

    @Test
    void builder_should_set_response_status_and_body() {
        String key = "key";
        String value = "value";
        ResponseEntity response = ResponseBuilder
            .status(SAMPLE_STATUS)
            .put(key, value)
            .build();

        Map<String, Object> body = (Map<String, Object>) response.getBody();

        assertAll(
            () -> assertEquals(SAMPLE_STATUS, response.getStatusCode()),
            () -> assertEquals(value, body.get(key))
        );
    }


}