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

package org.onap.pnfsimulator.message;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.onap.pnfsimulator.message.MessageConstants.COMMON_EVENT_HEADER;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT;
import static org.onap.pnfsimulator.message.MessageConstants.OTHER_FIELDS;
import org.json.JSONObject;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class MessageProviderTest {

    private static final String testParamsJson =
        "{\"key1\": \"val1\",\"key2\": \"val2\",\"pnfKey3\": \"pnfVal3\",\"key4\": \"val4\"}";

    private static MessageProvider messageProvider;

    @BeforeAll
    public static void setup() {
        messageProvider = new MessageProvider();
    }

    @Test
    public void createMessage_should_throw_when_given_null_argument() {
        assertThrows(IllegalArgumentException.class,
            () -> messageProvider.createMessage(null),
            "Params object cannot be null");
    }

    @Test
    public void createMessage_should_create_constant_message_when_no_params_specified() {
        JSONObject message = messageProvider.createMessage(new JSONObject());
        JSONObject event = message.getJSONObject(EVENT);

        JSONObject commonEventHeader = event.getJSONObject(COMMON_EVENT_HEADER);
        JSONObject otherFields = event.getJSONObject(OTHER_FIELDS);

        JSONObject expectedCommonEventHeader = JSONObjectFactory.generateConstantCommonEventHeader();
        JSONObject expectedOtherFields = JSONObjectFactory.generateConstantOtherFields();

        expectedCommonEventHeader
            .toMap()
            .forEach((key, val) -> assertTrue(commonEventHeader.has(key),
                () -> String.format("Key %s is not present", key)));

        expectedOtherFields
            .toMap()
            .forEach((key, val) -> assertTrue(otherFields.has(key),
                () -> String.format("Key %s is not present", key)));
    }


    @Test
    public void createMessage_should_add_specified_params_to_valid_subobjects() {
        JSONObject params = new JSONObject(testParamsJson);
        JSONObject message = messageProvider.createMessage(params);
        JSONObject event = message.getJSONObject(EVENT);

        JSONObject commonEventHeader = event.getJSONObject(COMMON_EVENT_HEADER);
        JSONObject otherFields = event.getJSONObject(OTHER_FIELDS);

        assertEquals("pnfVal3", otherFields.getString("pnfKey3"));
        assertEquals("val1", commonEventHeader.getString("key1"));
        assertEquals("val2", commonEventHeader.getString("key2"));
        assertEquals("val4", commonEventHeader.getString("key4"));
    }

}
