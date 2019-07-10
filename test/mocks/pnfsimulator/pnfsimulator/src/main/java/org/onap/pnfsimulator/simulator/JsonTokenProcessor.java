/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2018 Nokia. All rights reserved.
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
package org.onap.pnfsimulator.simulator;

import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonToken;
import com.google.gson.stream.JsonWriter;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.stream.Collectors;

public enum JsonTokenProcessor {
    STRING(JsonToken.STRING) {
        @Override
        void process(JsonReader reader, JsonWriter writer, int incrementValue, KeywordsExtractor keywordsExtractor)
                throws IOException {
            String originalString = reader.nextString();
            if (keywordsExtractor.isPrimitive(originalString)) {
                writer.value(keywordsExtractor.substitutePrimitiveKeyword(originalString));
            } else {
                String possibleSubstitution = Arrays.stream(originalString.split(" "))
                    .map(singleWord -> keywordsExtractor.substituteStringKeyword(singleWord, incrementValue)).collect(
                        Collectors.joining(" "));
                writer.value(originalString.equals(possibleSubstitution) ? originalString : possibleSubstitution);
            }
        }
    },
    BEGIN_ARRAY(JsonToken.BEGIN_ARRAY) {
        @Override
        void process(JsonReader reader, JsonWriter writer, int incrementValue, KeywordsExtractor keywordsExtractor)
                throws IOException {
            reader.beginArray();
            writer.beginArray();
        }
    },
    END_ARRAY(JsonToken.END_ARRAY) {
        @Override
        void process(JsonReader reader, JsonWriter writer, int incrementValue, KeywordsExtractor keywordsExtractor)
                throws IOException {
            reader.endArray();
            writer.endArray();
        }
    },
    BEGIN_OBJECT(JsonToken.BEGIN_OBJECT) {
        @Override
        void process(JsonReader reader, JsonWriter writer, int incrementValue, KeywordsExtractor keywordsExtractor)
                throws IOException {
            reader.beginObject();
            writer.beginObject();
        }
    },
    END_OBJECT(JsonToken.END_OBJECT) {
        @Override
        void process(JsonReader reader, JsonWriter writer, int incrementValue, KeywordsExtractor keywordsExtractor)
                throws IOException {
            reader.endObject();
            writer.endObject();
        }
    },
    NAME(JsonToken.NAME) {
        @Override
        void process(JsonReader reader, JsonWriter writer, int incrementValue, KeywordsExtractor keywordsExtractor)
                throws IOException {
            writer.name(reader.nextName());
        }
    },
    NUMBER(JsonToken.NUMBER) {
        @Override
        void process(JsonReader reader, JsonWriter writer, int incrementValue, KeywordsExtractor keywordsExtractor)
                throws IOException {
            writer.value(new BigDecimal(reader.nextString()));
        }
    },
    BOOLEAN(JsonToken.BOOLEAN) {
        @Override
        void process(JsonReader reader, JsonWriter writer, int incrementValue, KeywordsExtractor keywordsExtractor)
                throws IOException {
            writer.value(reader.nextBoolean());
        }
    },
    NULL(JsonToken.NULL) {
        @Override
        void process(JsonReader reader, JsonWriter writer, int incrementValue, KeywordsExtractor keywordsExtractor)
                throws IOException {
            reader.nextNull();
            writer.nullValue();
        }
    },
    END_DOCUMENT(JsonToken.END_DOCUMENT) {
        @Override
        void process(JsonReader reader, JsonWriter writer, int incrementValue, KeywordsExtractor keywordsExtractor)
                throws IOException {
            // do nothing
        }
    };

    private JsonToken jsonToken;

    JsonTokenProcessor(JsonToken jsonToken) {
        this.jsonToken = jsonToken;
    }

    boolean isProcessorFor(JsonToken jsonToken) {
        return this.jsonToken == jsonToken;
    }

    abstract void process(JsonReader reader, JsonWriter writer, int incrementValue, KeywordsExtractor keywordsExtractor) throws IOException;

    private static final String INVALID_JSON_BODY_UNSUPPORTED_JSON_TOKEN = "Invalid json body. Unsupported JsonToken.";

    static JsonTokenProcessor getProcessorFor(JsonToken jsonToken) throws IOException {
        return Arrays.stream(JsonTokenProcessor.values()).filter(processor -> processor.isProcessorFor(jsonToken)).findFirst()
                .orElseThrow(() -> new IOException(INVALID_JSON_BODY_UNSUPPORTED_JSON_TOKEN));
    }

}
