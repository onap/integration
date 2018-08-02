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