package org.onap.pnfsimulator.simulator.validation;

import static org.junit.jupiter.api.Assertions.assertThrows;

import com.github.fge.jsonschema.core.exceptions.InvalidSchemaException;
import com.github.fge.jsonschema.core.exceptions.ProcessingException;
import java.io.IOException;
import java.net.URL;
import org.json.JSONObject;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class JSONValidatorTest {

    private final static String VALID_SCHEMA_NAME = "valid-test-schema.json";
    private final static String INVALID_SCHEMA_NAME = "invalid-test-schema.json";

    private JSONValidator validator;

    @BeforeEach
    void setUp() {
        validator = new JSONValidator();
    }

    @Test
    void validate_should_not_throw_given_valid_json() throws ProcessingException, IOException, ValidationException {
        validator.validate(getValidJsonString(), getResourcePath(VALID_SCHEMA_NAME));
    }

    @Test
    void validate_should_not_throw_when_optional_parameter_missing()
        throws ProcessingException, IOException, ValidationException {

        String invalidJsonString = new JSONObject()
            .put("key1", "value1")
            .put("key2", "value2")
            .toString();

        validator.validate(invalidJsonString, getResourcePath(VALID_SCHEMA_NAME));
    }

    @Test
    void validate_should_throw_when_mandatory_parameter_missing() {

        String invalidJsonString = new JSONObject()
            .put("key1", "value1")
            .put("key3", "value3")
            .toString();

        assertThrows(
            ValidationException.class,
            () -> validator.validate(invalidJsonString, getResourcePath(VALID_SCHEMA_NAME)));
    }

    @Test
    void validate_should_throw_when_invalid_json_format() {
        String invalidJsonString = "{" +
            "\"key1\": \"value1\"" +
            "\"key2\": \"value2" +
            "}";

        assertThrows(
            IOException.class,
            () -> validator.validate(invalidJsonString, getResourcePath(VALID_SCHEMA_NAME)));
    }

    @Test
    void validate_should_throw_when_invalid_schema_format() {
        assertThrows(
            InvalidSchemaException.class,
            () -> validator.validate(getValidJsonString(), getResourcePath(INVALID_SCHEMA_NAME)));
    }

    @Test
    void validate_should_throw_when_invalid_schema_path() {

        assertThrows(
            IOException.class,
            () -> validator.validate(getValidJsonString(), "/not/existing/path/schema.json"));
    }

    private String getResourcePath(String schemaFileName) {
        URL result = getClass()
            .getClassLoader()
            .getResource(schemaFileName);

        if (result == null) {
            throw new IllegalArgumentException("Given file doesn't exist");
        } else {
            return result
                .toString()
                .replace("file:", "");
        }
    }

    private String getValidJsonString() {
        return new JSONObject()
            .put("key1", "value1")
            .put("key2", "value2")
            .put("key3", "value3")
            .toString();
    }
}