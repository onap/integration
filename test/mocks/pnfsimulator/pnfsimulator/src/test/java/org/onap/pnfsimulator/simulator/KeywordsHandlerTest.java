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

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
import static org.onap.pnfsimulator.simulator.KeywordsValueProvider.DEFAULT_STRING_LENGTH;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.Queue;
import org.junit.jupiter.api.Test;

class KeywordsHandlerTest {

    private static final String TEMPLATE_JSON = "{\n" +
        "  \"event\": {\n" +
        "    \"commonEventHeader\": {\n" +
        "      \"domain\": \"#RandomString\"\n" +
        "    },\n" +
        "    \"measurementsForVfScalingFields\": {\n" +
        "      \"measurementsForVfSclaingFieldsVersion\": 2.0,\n" +
        "      \"additionalMeasurements\": {\n" +
        "        \"name\": \"licenseUsage\",\n" +
        "        \"extraFields\": {\n" +
        "          \"name\": \"#RandomString(4)\",\n" +
        "          \"value\": \"1\"\n" +
        "        }\n" +
        "      }\n" +
        "    }\n" +
        "  }\n" +
        "}";

    private static final String TEMPLATE_JSON_WITH_MANY_KEYWORDS_INSIDE_SINGLE_VALUE = "{\n" +
        "  \"event\": {\n" +
        "    \"commonEventHeader\": {\n" +
        "      \"domain1\": \"#RandomString(1) #RandomString(2) #RandomString(3)\",\n" +
        "      \"domain2\": \"1 #RandomString(1) 2\"\n" +
        "    },\n" +
        "    \"measurementsForVfScalingFields\": {\n" +
        "      \"measurementsForVfSclaingFieldsVersion\": 2.0,\n" +
        "      \"additionalMeasurements\": {\n" +
        "        \"name\": \"licenseUsage\",\n" +
        "        \"extraFields\": {\n" +
        "          \"value\": \"1\"\n" +
        "        }\n" +
        "      }\n" +
        "    }\n" +
        "  }\n" +
        "}";

    private static final String TEMPLATE_JSON_WITH_ARRAY = "{\n"
        + "    \"event\": {\n"
        + "        \"commonEventHeader\": {\n"
        + "            \"domain\": \"#RandomString(1)\",\n"
        + "            \"version\": 2.0\n"
        + "        },\n"
        + "        \"measurementsForVfScalingFields\": {\n"
        + "            \"additionalMeasurements\": [\n"
        + "                {\n"
        + "                    \"name\": \"licenseUsage\",\n"
        + "                    \"arrayOfFields\": [\n"
        + "                        {\n"
        + "                            \"name\": \"G711AudioPort\",\n"
        + "                            \"value\": \"1\"\n"
        + "                        },\n"
        + "                        {\n"
        + "                            \"name\": [\"1\",\"2\"],\n"
        + "                            \"value\": \"#RandomString(2)\"\n"
        + "                        },\n"
        + "                        {\n"
        + "                            \"name\": \"G722AudioPort\",\n"
        + "                            \"value\": \"1\"\n"
        + "                        }\n"
        + "                    ]\n"
        + "                }\n"
        + "            ]\n"
        + "        }\n"
        + "    }\n"
        + "}";

    private static final String TEMPLATE_ONE_INCREMENT_JSON = "{\n" +
        "  \"event\": {\n" +
        "    \"commonEventHeader\": {\n" +
        "      \"domain\": \"#RandomString\"\n" +
        "    },\n" +
        "    \"measurementsForVfScalingFields\": {\n" +
        "      \"measurementsForVfSclaingFieldsVersion\": 2.0,\n" +
        "      \"additionalMeasurements\": {\n" +
        "        \"name\": \"licenseUsage\",\n" +
        "        \"extraFields\": {\n" +
        "          \"name\": \"#RandomString(4)\",\n" +
        "          \"value\": \"#Increment\"\n" +
        "        }\n" +
        "      }\n" +
        "    }\n" +
        "  }\n" +
        "}";

    private static final String TEMPLATE_WITH_SIMPLE_VALUE= "\"#RandomString(4)\"";

    private static final String TEMPLATE_WITH_ARRAY_OF_PRIMITIVES = "[ 1, \"#RandomString(5)\", 3]";

    private static final String TEMPLATE_TWO_INCREMENT_JSON = "{\n" +
        "  \"event\": {\n" +
        "    \"commonEventHeader\": {\n" +
        "      \"domain\": \"#RandomString\"\n" +
        "    },\n" +
        "    \"measurementsForVfScalingFields\": {\n" +
        "      \"measurementsForVfSclaingFieldsVersion\": 2.0,\n" +
        "      \"additionalMeasurements\": {\n" +
        "        \"name\": \"licenseUsage\",\n" +
        "        \"extraFields\": {\n" +
        "          \"name\": \"#RandomString(4)\",\n" +
        "          \"value\": \"#Increment\",\n" +
        "          \"otherValue\": \"#Increment\"\n" +
        "        }\n" +
        "      }\n" +
        "    }\n" +
        "  }\n" +
        "}";

    private Gson gson = new Gson();

    @Test
    void shouldReplaceRandomStringKeyword() {
        // given
        JsonObject templateJson = gson.fromJson(TEMPLATE_JSON, JsonObject.class);
        KeywordsHandler keywordsHandler = new KeywordsHandler(new KeywordsExtractor(), (id) -> 1);

        // when
        JsonObject resultJson = keywordsHandler.substituteKeywords(templateJson, "").getAsJsonObject();

        // then
        String extraFields = resultJson
            .get("event").getAsJsonObject()
            .get("measurementsForVfScalingFields").getAsJsonObject()
            .get("additionalMeasurements").getAsJsonObject()
            .get("extraFields").getAsJsonObject()
            .get("name").getAsString();
        String newDomain = resultJson
            .get("event").getAsJsonObject()
            .get("commonEventHeader").getAsJsonObject()
            .get("domain").getAsString();

        assertThat(extraFields.length()).isEqualTo(4);
        assertThat(newDomain.length()).isEqualTo(DEFAULT_STRING_LENGTH);
    }

    @Test
    void shouldReplaceRandomStringKeywordsInsideSingleValue() {
        // given
        JsonObject templateJson = gson.fromJson(TEMPLATE_JSON_WITH_MANY_KEYWORDS_INSIDE_SINGLE_VALUE, JsonObject.class);
        KeywordsHandler keywordsHandler = new KeywordsHandler(new KeywordsExtractor(), (id) -> 1);

        // when
        JsonObject resultJson = keywordsHandler.substituteKeywords(templateJson, "").getAsJsonObject();

        // then
        String newDomain1 = resultJson
            .get("event").getAsJsonObject()
            .get("commonEventHeader").getAsJsonObject()
            .get("domain1").getAsString();
        String newDomain2 = resultJson
            .get("event").getAsJsonObject()
            .get("commonEventHeader").getAsJsonObject()
            .get("domain2").getAsString();

        assertThat(newDomain1.length()).isEqualTo(1+1+2+1+3);
        assertThat(newDomain2.length()).isEqualTo(1+1+1+1+1);
    }

    @Test
    void shouldReplaceRandomStringKeywordInTeplateAsArrayWithPrimitves() {
        // given
        JsonElement templateJson = gson.fromJson(TEMPLATE_WITH_ARRAY_OF_PRIMITIVES, JsonElement.class);
        KeywordsHandler keywordsHandler = new KeywordsHandler(new KeywordsExtractor(), (id) -> 1);

        // when
        JsonElement resultJson = keywordsHandler.substituteKeywords(templateJson, "");
        assertThat(resultJson.getAsJsonArray().get(1).getAsString().length()).isEqualTo(5);
    }

    @Test
    void shouldReplaceRandomStringKeywordInTeplateAsSimpleValue() {
        // given
        JsonElement templateJson = gson.fromJson(TEMPLATE_WITH_SIMPLE_VALUE, JsonElement.class);
        KeywordsHandler keywordsHandler = new KeywordsHandler(new KeywordsExtractor(), (id) -> 1);

        // when
        JsonElement resultJson = keywordsHandler.substituteKeywords(templateJson, "");

        // then
        assertThat(resultJson.getAsString().length()).isEqualTo(4);
    }

    @Test
    void shouldReplaceRandomStringKeywordInTeplateWithJsonArray() {
        // given
        JsonElement templateJson = gson.fromJson(TEMPLATE_JSON_WITH_ARRAY, JsonElement.class);
        KeywordsHandler keywordsHandler = new KeywordsHandler(new KeywordsExtractor(), (id) -> 1);

        // when
        JsonObject resultJson = keywordsHandler.substituteKeywords(templateJson, "").getAsJsonObject();

        // then
        String actualValue = resultJson
            .get("event").getAsJsonObject()
            .get("measurementsForVfScalingFields").getAsJsonObject()
            .get("additionalMeasurements").getAsJsonArray()
            .get(0).getAsJsonObject()
            .get("arrayOfFields").getAsJsonArray()
            .get(1).getAsJsonObject()
            .get("value").getAsString();
        String otherActualValue = resultJson
            .get("event").getAsJsonObject()
            .get("commonEventHeader").getAsJsonObject()
            .get("domain").getAsString();

        assertThat(otherActualValue.length()).isEqualTo(1);
        assertThat(actualValue.length()).isEqualTo(2);
    }

    @Test
    void shouldReplaceOneIncrementKeyword() {
        // given
        final Integer newIncrementedValue = 2;
        JsonObject templateJson = gson.fromJson(TEMPLATE_ONE_INCREMENT_JSON, JsonObject.class);
        KeywordsHandler keywordsHandler = new KeywordsHandler(new KeywordsExtractor(), (id) -> newIncrementedValue);

        // when
        JsonObject resultJson = keywordsHandler.substituteKeywords(templateJson, "some random id").getAsJsonObject();

        // then
        String actualValue = resultJson
            .get("event").getAsJsonObject()
            .get("measurementsForVfScalingFields").getAsJsonObject()
            .get("additionalMeasurements").getAsJsonObject()
            .get("extraFields").getAsJsonObject()
            .get("value").getAsString();

        assertThat(actualValue).isEqualTo(newIncrementedValue.toString());
    }

    @Test
    void shouldReplaceTwoIncrementKeyword() {
        // given
        final Integer firstIncrementValue = 2;
        final Integer secondIncrementValue = 3;
        JsonObject templateJson = gson.fromJson(TEMPLATE_TWO_INCREMENT_JSON, JsonObject.class);
        KeywordsHandler keywordsHandler = new KeywordsHandler(new KeywordsExtractor(), new IncrementProvider() {
            Queue<Integer> sequenceOfValues = new LinkedList<>(
                Arrays.asList(firstIncrementValue, secondIncrementValue));

            @Override
            public int getAndIncrement(String id) {
                return sequenceOfValues.poll();
            }
        });

        // when
        JsonObject resultJson = keywordsHandler.substituteKeywords(templateJson, "some random id").getAsJsonObject();
        resultJson = keywordsHandler.substituteKeywords(templateJson, "some random id").getAsJsonObject();

        // then
        String actualValue = resultJson
            .get("event").getAsJsonObject()
            .get("measurementsForVfScalingFields").getAsJsonObject()
            .get("additionalMeasurements").getAsJsonObject()
            .get("extraFields").getAsJsonObject()
            .get("value").getAsString();

        String actualOtherValue = resultJson
            .get("event").getAsJsonObject()
            .get("measurementsForVfScalingFields").getAsJsonObject()
            .get("additionalMeasurements").getAsJsonObject()
            .get("extraFields").getAsJsonObject()
            .get("otherValue").getAsString();

        assertThat(actualValue).isEqualTo(secondIncrementValue.toString());
        assertThat(actualOtherValue).isEqualTo(secondIncrementValue.toString());

    }
}
