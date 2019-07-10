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

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonToken;
import com.google.gson.stream.JsonWriter;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import org.springframework.stereotype.Component;

@Component
public class KeywordsHandler {

    private KeywordsExtractor keywordsExtractor;
    private IncrementProvider incrementProvider;

    public KeywordsHandler(KeywordsExtractor keywordsExtractor, IncrementProvider incrementProvider) {
        this.keywordsExtractor = keywordsExtractor;
        this.incrementProvider = incrementProvider;
    }

    public JsonElement substituteKeywords(JsonElement jsonBody, String jobId) {
        int counter = incrementProvider.getAndIncrement(jobId);
        try (
            JsonReader reader = new JsonReader(new StringReader(jsonBody.toString()));
            StringWriter stringWriter = new StringWriter();
            JsonWriter jsonWriter = new JsonWriter(stringWriter);
        ) {
            modify(reader, jsonWriter, counter);
            return new Gson().fromJson(stringWriter.getBuffer().toString(), JsonElement.class);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private void modify(JsonReader reader, JsonWriter writer, int incrementValue) throws IOException {
        JsonTokenProcessor jsonTokenProcessor;
        do {
            JsonToken token = reader.peek();
            jsonTokenProcessor = JsonTokenProcessor.getProcessorFor(token);
            jsonTokenProcessor.process(reader, writer, incrementValue, keywordsExtractor);
        } while (isJsonProcessingFinished(jsonTokenProcessor));
    }

    private boolean isJsonProcessingFinished(JsonTokenProcessor jsonTokenProcessor) {
        return !jsonTokenProcessor.isProcessorFor(JsonToken.END_DOCUMENT);
    }

}


