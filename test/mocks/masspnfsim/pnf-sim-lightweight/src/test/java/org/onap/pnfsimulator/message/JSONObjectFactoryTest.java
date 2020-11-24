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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT_ID;
import static org.onap.pnfsimulator.message.MessageConstants.INTERNAL_HEADER_FIELDS;
import static org.onap.pnfsimulator.message.MessageConstants.LAST_EPOCH_MICROSEC;
import static org.onap.pnfsimulator.message.MessageConstants.NOTIFICATION_FIELDS_VERSION;
import static org.onap.pnfsimulator.message.MessageConstants.NOTIFICATION_FIELDS_VERSION_VALUE;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_LAST_SERVICE_DATE;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_MANUFACTURE_DATE;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_REGISTRATION_FIELDS_VERSION;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_REGISTRATION_FIELDS_VERSION_VALUE;
import static org.onap.pnfsimulator.message.MessageConstants.PRIORITY;
import static org.onap.pnfsimulator.message.MessageConstants.PRIORITY_NORMAL;
import static org.onap.pnfsimulator.message.MessageConstants.REPORTING_ENTITY_NAME;
import static org.onap.pnfsimulator.message.MessageConstants.SEQUENCE;
import static org.onap.pnfsimulator.message.MessageConstants.SEQUENCE_NUMBER;
import static org.onap.pnfsimulator.message.MessageConstants.SOURCE_NAME;
import static org.onap.pnfsimulator.message.MessageConstants.START_EPOCH_MICROSEC;
import static org.onap.pnfsimulator.message.MessageConstants.TIME_ZONE_OFFSET;
import static org.onap.pnfsimulator.message.MessageConstants.VERSION;
import static org.onap.pnfsimulator.message.MessageConstants.VERSION_NUMBER;
import static org.onap.pnfsimulator.message.MessageConstants.VES_EVENT_LISTENER_VERSION;
import static org.onap.pnfsimulator.message.MessageConstants.VES_EVENT_LISTENER_VERSION_NUMBER;
import org.json.JSONObject;
import org.junit.jupiter.api.Test;

public class JSONObjectFactoryTest {

    @Test
    public void generateConstantCommonEventHeader_shouldCreateProperly(){
        JSONObject commonEventHeader = JSONObjectFactory.generateConstantCommonEventHeader();
        assertEquals(11,commonEventHeader.toMap().size());
        assertTrue(commonEventHeader.has(EVENT_ID));
        assertTrue(commonEventHeader.has(TIME_ZONE_OFFSET));
        assertTrue(commonEventHeader.has(LAST_EPOCH_MICROSEC));
        assertTrue(commonEventHeader.has(PRIORITY));
        assertTrue(commonEventHeader.has(SEQUENCE));
        assertTrue(commonEventHeader.has(START_EPOCH_MICROSEC));
        assertTrue(commonEventHeader.has(INTERNAL_HEADER_FIELDS));
        assertTrue(commonEventHeader.has(VERSION));
        assertTrue(commonEventHeader.has(SOURCE_NAME));
        assertTrue(commonEventHeader.has(REPORTING_ENTITY_NAME));
        assertEquals(commonEventHeader.get(PRIORITY),PRIORITY_NORMAL);
        assertEquals(commonEventHeader.get(SEQUENCE),SEQUENCE_NUMBER);
        assertEquals(commonEventHeader.get(VERSION),VERSION_NUMBER);
        assertEquals(commonEventHeader.get(VES_EVENT_LISTENER_VERSION),VES_EVENT_LISTENER_VERSION_NUMBER);
    }

    @Test
    public void generateConstantPnfRegistrationFields_shouldCreateProperly(){
        JSONObject pnfRegistrationFields = JSONObjectFactory.generatePnfRegistrationFields();
        assertEquals(3,pnfRegistrationFields.toMap().size());
        assertTrue(pnfRegistrationFields.has(PNF_REGISTRATION_FIELDS_VERSION));
        assertEquals(pnfRegistrationFields.get(PNF_REGISTRATION_FIELDS_VERSION), PNF_REGISTRATION_FIELDS_VERSION_VALUE);
        assertTrue(pnfRegistrationFields.has(PNF_LAST_SERVICE_DATE));
        assertTrue(pnfRegistrationFields.has(PNF_MANUFACTURE_DATE));
    }

    @Test
    public void generateEventId_shouldCreateProperly(){
        String eventId = JSONObjectFactory.generateEventId();
        assertTrue(eventId.startsWith("FileReady_"));
    }

    @Test
    public void generateNotificationFields_shouldCreateProperly(){
        JSONObject notificationFields = JSONObjectFactory.generateNotificationFields();
        assertEquals(1,notificationFields.keySet().size());
        assertEquals(NOTIFICATION_FIELDS_VERSION_VALUE,notificationFields.get(NOTIFICATION_FIELDS_VERSION));

    }

}
