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

package org.onap.pnfsimulator.simulator.validation;

import com.fasterxml.jackson.databind.JsonNode;
import com.github.fge.jackson.JsonLoader;
import com.github.fge.jsonschema.core.exceptions.ProcessingException;
import com.github.fge.jsonschema.core.report.LogLevel;
import com.github.fge.jsonschema.core.report.ProcessingMessage;
import com.github.fge.jsonschema.core.report.ProcessingReport;
import com.github.fge.jsonschema.main.JsonSchema;
import com.github.fge.jsonschema.main.JsonSchemaFactory;
import com.google.gson.JsonParser;
import java.io.FileReader;
import java.io.IOException;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

public class JSONValidator {

    public void validate(String data, String jsonSchemaPath)
        throws ValidationException, ProcessingException, IOException {
        String jsonSchema = readJsonSchemaAsString(jsonSchemaPath);
        JsonNode jsonData = JsonLoader.fromString(data);
        ProcessingReport report = createJsonSchema(jsonSchema).validate(jsonData);

        if (!report.isSuccess()) {
            throw new ValidationException(constructValidationErrors(report));
        }
    }

    private String readJsonSchemaAsString(String schemaPath) throws IOException {
        try (FileReader reader = new FileReader(schemaPath)) {
            return new JsonParser().parse(reader).toString();
        }
    }

    private JsonSchema createJsonSchema(String schema) throws ProcessingException, IOException {
        return JsonSchemaFactory.byDefault().getJsonSchema(JsonLoader.fromString(schema));
    }

    private String constructValidationErrors(ProcessingReport report) {
        return StreamSupport.stream(report.spliterator(), false)
            .filter(entry -> entry.getLogLevel() == LogLevel.ERROR)
            .map(ProcessingMessage::getMessage)
            .collect(Collectors.joining("\n"));
    }
}
