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
import com.google.gson.JsonObject;
import org.assertj.core.api.AssertionsForInterfaceTypes;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;

class TemplatePatcherTest {

    private static final String TEMPLATE_JSON = "{\n" +
            "  \"event\": {\n" +
            "    \"commonEventHeader\": {\n" +
            "      \"domain\": \"measurementsForVfScaling\"\n" +
            "    },\n" +
            "    \"measurementsForVfScalingFields\": {\n" +
            "      \"measurementsForVfSclaingFieldsVersion\": 2.0,\n" +
            "      \"additionalMeasurements\": {\n" +
            "        \"name\": \"licenseUsage\",\n" +
            "        \"extraFields\": {\n" +
            "          \"name\": \"G711AudioPort\",\n" +
            "          \"value\": \"1\"\n" +
            "        }\n" +
            "      }\n" +
            "    }\n" +
            "  }\n" +
            "}";

    private TemplatePatcher templatePatcher;
    private Gson gson = new Gson();
    private JsonObject templateJson;

    @BeforeEach
    void setUp() {
        templatePatcher = new TemplatePatcher();
        templateJson = gson.fromJson(TEMPLATE_JSON, JsonObject.class);
    }

    @Test
    void shouldReplaceJsonElementsInTemplate() {
        //given
        String patchJsonString = "{\n"
                + "  \"event\": {\n"
                + "    \"commonEventHeader\": {\n"
                + "      \"domain\": \"newDomain\"\n"
                + "    }\n"
                + "  }\n"
                + "}";
        JsonObject patchJson = gson.fromJson(patchJsonString, JsonObject.class);

        //when
        JsonObject requestJson = templatePatcher.mergeTemplateWithPatch(templateJson, patchJson);

        //then
        String newDomain = requestJson
                .get("event").getAsJsonObject()
                .get("commonEventHeader").getAsJsonObject()
                .get("domain").getAsString();
        assertThat(newDomain).isEqualTo("newDomain");
    }

    @Test
    void shouldAddWholeJsonObjectToTemplateWhenItFinished() {
        //given
        String patchJsonString =
                "{\n"
                        + " \"event\": {\n"
                        + "  \"commonEventHeader\": {\n"
                        + "   \"domain\": {\n"
                        + "    \"extraFields\": {\n"
                        + "     \"name\": \"G711AudioPort\",\n"
                        + "     \"value\": \"1\"\n"
                        + "    }\n"
                        + "   }\n"
                        + "  }\n"
                        + " }\n"
                        + "}";
        JsonObject patchJson = gson.fromJson(patchJsonString, JsonObject.class);

        //when
        JsonObject requestJson = templatePatcher.mergeTemplateWithPatch(templateJson, patchJson);

        //then
        JsonElement newDomain = requestJson
                .get("event").getAsJsonObject()
                .get("commonEventHeader").getAsJsonObject()
                .get("domain");
        assertThat(newDomain.isJsonObject()).isTrue();
        JsonObject newDomainJO = newDomain.getAsJsonObject();
        AssertionsForInterfaceTypes.assertThat(newDomainJO.keySet()).containsExactly("extraFields");
        JsonObject newDomainExtraFields = newDomainJO.get("extraFields").getAsJsonObject();
        AssertionsForInterfaceTypes.assertThat(newDomainExtraFields.keySet()).containsExactly("name", "value");
    }

    @Test
    void shouldReplaceJsonObjectWithJsonElementFromPatch() {
        //given
        String patchJsonString = "{ \"event\": \"test\" }";
        JsonObject patchJson = gson.fromJson(patchJsonString, JsonObject.class);

        //when
        JsonObject requestJson = templatePatcher.mergeTemplateWithPatch(templateJson, patchJson);

        //then
        assertThat(requestJson.get("event").isJsonObject()).isFalse();
        assertThat(requestJson.get("event").getAsString()).isEqualTo("test");
    }

    @Test
    void shouldAddNewKeyIfPatchHasItAndTempleteDoesnt() {
        //given
        String patchJsonString = "{  \"newTestKey\": { \"newTestKeyChild\":\"newTestValue\"  }}";
        JsonObject patchJson = gson.fromJson(patchJsonString, JsonObject.class);

        //when
        JsonObject requestJson = templatePatcher.mergeTemplateWithPatch(templateJson, patchJson);

        //then
        assertThat(requestJson.get("event").isJsonObject()).isTrue();
        assertThat(requestJson.get("newTestKey").isJsonObject()).isTrue();
        JsonObject newTestKey = requestJson.get("newTestKey").getAsJsonObject();
        AssertionsForInterfaceTypes.assertThat(newTestKey.keySet()).containsExactly("newTestKeyChild");
        assertThat(newTestKey.get("newTestKeyChild").getAsString()).isEqualTo("newTestValue");

    }


    @Test
    void shouldNotChangeInputTemplateParam() {
        //given
        String patchJsonString = "{  \"newTestKey\": { \"newTestKeyChild\":\"newTestValue\"  }}";
        JsonObject patchJson = gson.fromJson(patchJsonString, JsonObject.class);

        //when
        templatePatcher.mergeTemplateWithPatch(templateJson, patchJson);

        //then
        assertThat(templateJson).isEqualTo(gson.fromJson(TEMPLATE_JSON, JsonObject.class));

    }
}
