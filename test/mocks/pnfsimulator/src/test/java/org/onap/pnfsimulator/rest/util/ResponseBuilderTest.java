/*-
 * ============LICENSE_START=======================================================
 * org.onap.integration
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

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import java.util.Map;
import static org.junit.jupiter.api.Assertions.*;

public class ResponseBuilderTest {

    private static final int SAMPLE_STATUS_CODE = 200;
    private ResponseBuilder builder;

    @BeforeEach
    void setup() {
        builder = ResponseBuilder.status(SAMPLE_STATUS_CODE);
    }

    @Test
    void checkResponseBodySize() {
        builder.put("sample", "sample");
        ResponseEntity responseEntity = builder.build();
        Map<String, Object> body = (Map<String, Object>) responseEntity.getBody();

        assertEquals(body.size(), 1);
    }

    @Test
    void buildProperResponseEntity() {
        ResponseEntity responseEntity = builder.build();

        assertAll(
            () -> assertEquals(responseEntity.getStatusCode(), HttpStatus.OK),
            () -> assertNull(responseEntity.getBody())
        );
    }

}