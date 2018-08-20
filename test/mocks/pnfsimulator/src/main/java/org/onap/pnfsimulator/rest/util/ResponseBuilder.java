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

import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

public class ResponseBuilder {

    public static final String TIMESTAMP = "timestamp";
    public static final String MESSAGE = "message";
    public static final String SIMULATOR_STATUS = "simulatorStatus";
    public static final String REMAINING_TIME = "remainingTime";

    private HttpStatus httpStatus;
    private Map<String, Object> body = new LinkedHashMap<>();

    private ResponseBuilder(HttpStatus httpStatus) {
        this.httpStatus = httpStatus;
    }

    public static ResponseBuilder status(HttpStatus httpStatus) {

        return new ResponseBuilder(httpStatus);
    }

    public ResponseBuilder put(String key, Object value) {

        body.put(key, value);
        return this;
    }

    public ResponseEntity build() {

        if (body.isEmpty()) {
            return ResponseEntity.status(httpStatus).build();
        }

        return ResponseEntity.status(httpStatus).body(body);
    }

}
