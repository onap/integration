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
