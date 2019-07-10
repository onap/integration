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
import com.google.gson.JsonObject;
import com.google.gson.JsonSyntaxException;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.test.context.TestPropertySource;

import java.io.IOException;

import static org.assertj.core.api.Java6Assertions.assertThat;

@TestPropertySource
class TemplateReaderTest {

    private FilesystemTemplateReader templateReader = new FilesystemTemplateReader("src/test/resources/org/onap/pnfsimulator/simulator/", new Gson());

    @Test
    void testShouldReadJsonFromFile() throws IOException {
        JsonObject readJson = templateReader.readTemplate("validExampleMeasurementEvent.json");
        assertThat(readJson.keySet()).containsOnly("event");
        assertThat(readJson.get("event").getAsJsonObject().keySet()).containsExactlyInAnyOrder("commonEventHeader", "measurementsForVfScalingFields");
    }

    @Test
    void testShouldRaiseExceptionWhenInvalidJsonIsRead() {
        Assertions.assertThrows(JsonSyntaxException.class, () -> templateReader.readTemplate("invalidJsonStructureEvent.json"));
    }

}
