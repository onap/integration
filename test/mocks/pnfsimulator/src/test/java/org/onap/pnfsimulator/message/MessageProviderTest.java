/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2018-2019 NOKIA Intellectual Property. All rights reserved.
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

import org.json.JSONObject;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.data.MapEntry.entry;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.onap.pnfsimulator.message.MessageConstants.COMMON_EVENT_HEADER;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT;
import static org.onap.pnfsimulator.message.MessageConstants.NOTIFICATION_FIELDS;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_REGISTRATION_FIELDS;

public class MessageProviderTest {

    private static final String testParamsPnfRegistration =
            "{\"pnfKey1\": \"pnfVal1\",\"pnfKey2\": \"pnfVal2\",\"pnfKey3\": \"pnfVal3\",\"pnfKey4\": \"pnfVal4\"}";

    private static final String testParamsNotification =
            "{\"notKey1\": \"notVal1\",\"notKey2\": \"notVal2\",\"notKey3\": \"notVal3\",\"notKey4\": \"notVal4\"}";

    private static MessageProvider messageProvider;

    @BeforeAll
    public static void setup() {
        messageProvider = new MessageProvider();
    }

    @Test
    public void createMessageWithPnfRegistration_should_create_constant_message_when_no_params_specified() {
        JSONObject message = messageProvider.createMessageWithPnfRegistration(new JSONObject(), new JSONObject());
        JSONObject event = message.getJSONObject(EVENT);

        JSONObject commonEventHeader = event.getJSONObject(COMMON_EVENT_HEADER);
        JSONObject pnfRegistrationFields = event.getJSONObject(PNF_REGISTRATION_FIELDS);

        JSONObject expectedCommonEventHeader = JSONObjectFactory.generateConstantCommonEventHeader();
        JSONObject expectedPnfRegistrationFields = JSONObjectFactory.generatePnfRegistrationFields();

        assertThat(commonEventHeader.keySet())
                .containsAll(expectedCommonEventHeader.keySet());
        assertThat(pnfRegistrationFields.keySet())
                .containsAll(expectedPnfRegistrationFields.keySet());
    }

    @Test
    public void createMessageWithNotification_should_create_constant_message_when_no_params_specified() {
        JSONObject message = messageProvider.createMessageWithNotification(new JSONObject(),
                new JSONObject());
        JSONObject event = message.getJSONObject(EVENT);

        JSONObject commonEventHeader = event.getJSONObject(COMMON_EVENT_HEADER);
        JSONObject notificationFields = event.getJSONObject(NOTIFICATION_FIELDS);

        JSONObject expectedCommonEventHeader = JSONObjectFactory.generateConstantCommonEventHeader();
        JSONObject expectedNotificationFields = JSONObjectFactory.generateNotificationFields();

        assertThat(commonEventHeader.keySet())
                .containsAll(expectedCommonEventHeader.keySet());

        assertThat(notificationFields.keySet())
                .containsAll(expectedNotificationFields.keySet());
    }

    @Test
    public void createMessageWithPnfRegistration_should_add_specified_params_to_valid_subobjects() {
        JSONObject message = messageProvider
                .createMessageWithPnfRegistration(new JSONObject(), new JSONObject(testParamsPnfRegistration));
        JSONObject event = message.getJSONObject(EVENT);

        JSONObject commonEventHeader = event.getJSONObject(COMMON_EVENT_HEADER);

        JSONObject pnfRegistrationFields = event.getJSONObject(PNF_REGISTRATION_FIELDS);
        assertThat(pnfRegistrationFields.toMap()).contains(
                entry("pnfKey1", "pnfVal1"),
                entry("pnfKey2", "pnfVal2"),
                entry("pnfKey3", "pnfVal3"),
                entry("pnfKey4", "pnfVal4")
        );
    }

    @Test
    public void createMessageWithNotification_should_add_specified_params_to_valid_subobjects() {
        JSONObject message = messageProvider
                .createMessageWithNotification(new JSONObject(),
                        new JSONObject(testParamsNotification));
        JSONObject event = message.getJSONObject(EVENT);

        JSONObject notificationFields = event.getJSONObject(NOTIFICATION_FIELDS);
        assertThat(notificationFields.toMap()).contains(
                entry("notKey1", "notVal1"),
                entry("notKey2", "notVal2"),
                entry("notKey3", "notVal3"),
                entry("notKey4", "notVal4")
        );
        assertEquals("notVal1", notificationFields.getString("notKey1"));
        assertEquals("notVal2", notificationFields.getString("notKey2"));

    }

}
