/*-
 * ============LICENSE_START=======================================================
 * Simulator
 * ================================================================================
 * Copyright (C) 2019 Nokia. All rights reserved.
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

package org.onap.pnfsimulator.template.search;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import org.bson.Document;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Java6Assertions.assertThat;

class JsonUtilsTest {

    private static final Gson GSON_HELPER = new Gson();
    private JsonUtils utils;

    @BeforeEach
    void setUp() {
        utils = new JsonUtils();
    }

    private static final String NOTIFICATION_JSON = "{\n\"event\": {\n" +
            "    \"commonEventHeader\": {\n" +
            "      \"domain\": \"notification\",\n" +
            "      \"eventName\": \"vFirewallBroadcastPackets\"\n" +
            "    },\n" +
            "    \"notificationFields\": {\n" +
            "      \"changeIdentifier\": \"PM_MEAS_FILES\",\n" +
            "      \"arrayOfNamedHashMap\": [{\n" +
            "        \"name\": \"A20161221.1031-1041.bin.gz\",\n" +
            "        \"hashMap\": {\n" +
            "          \"fileformatType\": \"org.3GPP.32.435#measCollec\",\n" +
            "          \"fileFormatVersion\": \"V10\"\n"+
            "        }\n" +
            "      }, {\n" +
            "        \"name\": \"A20161222.1042-1102.bin.gz\",\n" +
            "        \"hashMap\": {\n" +
            "          \"fileFormatType\": \"org.3GPP.32.435#measCollec\",\n" +
            "          \"fileFormatVersion\": \"1.0.0\"\n" +
            "        }\n" +
            "      }],\n" +
            "      \"notificationFieldsVersion\": \"2.0\"\n}\n\n}}";
    private static final String EXPECTED_FLATTENED_NOTIFICATION = "{" +
            " \":event:commonEventHeader:domain\" : \"notification\"," +
            " \":event:commonEventHeader:eventName\" : \"vFirewallBroadcastPackets\"," +
            " \":event:notificationFields:changeIdentifier\" : \"PM_MEAS_FILES\"," +
            " \":event:notificationFields:arrayOfNamedHashMap[0]:name\" : \"A20161221.1031-1041.bin.gz\"," +
            " \":event:notificationFields:arrayOfNamedHashMap[0]:hashMap:fileformatType\" : \"org.3GPP.32.435#measCollec\"," +
            " \":event:notificationFields:arrayOfNamedHashMap[0]:hashMap:fileFormatVersion\" : \"V10\"," +
            " \":event:notificationFields:arrayOfNamedHashMap[1]:name\" : \"A20161222.1042-1102.bin.gz\"," +
            " \":event:notificationFields:arrayOfNamedHashMap[1]:hashMap:fileFormatType\" : \"org.3GPP.32.435#measCollec\"," +
            " \":event:notificationFields:arrayOfNamedHashMap[1]:hashMap:fileFormatVersion\" : \"1.0.0\"," +
            " \":event:notificationFields:notificationFieldsVersion\" : \"2.0\" }";

    @Test
    void shouldFlattenNestedJsonAndSeparateKeysWithDoubleHash(){
        JsonObject templateJson = GSON_HELPER.fromJson(NOTIFICATION_JSON, JsonObject.class);

        JsonObject result = utils.flatten(templateJson);

        assertThat(result).isEqualTo(GSON_HELPER.fromJson(EXPECTED_FLATTENED_NOTIFICATION, JsonObject.class));
    }

    @Test
    void shouldWorkOnEmptyJsonObject(){
        JsonObject result = utils.flatten(new JsonObject());

        assertThat(result.toString()).isEqualTo("{}");
    }

    @Test
    void shouldFlattenObjectWithArrayValue(){
        String expectedFlattenedObjectWithArray = "{" +
                " \":sample[0]\": 1," +
                " \":sample[1]\": 2," +
                " \":sample[2]\": 3}";
        JsonObject jsonWithPrimitivesArray = GSON_HELPER.fromJson("{\"sample\": [1, 2, 3]}", JsonObject.class);

        JsonObject result = utils.flatten(jsonWithPrimitivesArray);

        assertThat(result).isEqualTo(GSON_HELPER.fromJson(expectedFlattenedObjectWithArray, JsonObject.class));
    }

    @Test
    void shouldFlattenObjectWithEmptyArrayValue(){
        String expectedFlattenedObjectWithEmptyArray = "{\":sample\": []}";
        JsonObject jsonWithEmptyArrayValue = GSON_HELPER.fromJson("{\"sample\": []}", JsonObject.class);

        JsonObject result = utils.flatten(jsonWithEmptyArrayValue);

        assertThat(result).isEqualTo(GSON_HELPER.fromJson(expectedFlattenedObjectWithEmptyArray, JsonObject.class));
    }

    @Test
    void shouldFlattenNestedObjectWithEmptyObjectValue(){
        String expectedFlattenedNestedObjectWithEmptyObject = "{\":sample:key\": {}}";
        JsonObject nestedJsonWithEmptyObject = GSON_HELPER.fromJson("{\"sample\": {\"key\":{}}}", JsonObject.class);

        JsonObject result = utils.flatten(nestedJsonWithEmptyObject);

        assertThat(result).isEqualTo(GSON_HELPER.fromJson(expectedFlattenedNestedObjectWithEmptyObject, JsonObject.class));
    }

    @Test
    void shouldFlattenObjectWithDifferentDataTypes(){
        String jsonWithDifferentDataTypes = "{ \"topLevelKey\": {\"sampleInt\": 1, \"sampleBool\": false, \"sampleDouble\": 10.0, \"sampleString\": \"str\"}}";
        String expectedResult = "{\":topLevelKey:sampleInt\": 1," +
                " \":topLevelKey:sampleBool\": \"false\"," +
                " \":topLevelKey:sampleDouble\": 10.0," +
                " \":topLevelKey:sampleString\": \"str\"}";
        JsonObject templateJson = GSON_HELPER.fromJson(jsonWithDifferentDataTypes, JsonObject.class);

        JsonObject result = utils.flatten(templateJson);

        assertThat(result).isEqualTo(GSON_HELPER.fromJson(expectedResult, JsonObject.class));
    }

    @Test
    void shouldHandleNullValues(){
        String jsonWithNullValue = "{ \"topLevelKey\": {\"sampleNull\": null, \"sampleString\": \"str\"}}";
        String expectedResult = "{\":topLevelKey:sampleNull\": null," +
                " \":topLevelKey:sampleString\": \"str\"}";
        JsonObject templateJson = GSON_HELPER.fromJson(jsonWithNullValue, JsonObject.class);

        JsonObject result = utils.flatten(templateJson);

        assertThat(result).isEqualTo(GSON_HELPER.fromJson(expectedResult, JsonObject.class));
    }

    @Test
    void shouldFlattenBsonDocument(){
        Document documentInput = Document.parse(NOTIFICATION_JSON);

        Document result = utils.flatten(documentInput);

        assertThat(result.toJson()).isEqualTo(EXPECTED_FLATTENED_NOTIFICATION);
    }

    @Test
    void shouldNotChangeEmptyBsonDocument(){
        Document input = Document.parse("{}");

        Document result = utils.flatten(input);

        assertThat(result.toJson()).isEqualTo("{ }");
    }
}
