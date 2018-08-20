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
import static org.onap.pnfsimulator.message.MessageConstants.*;

import org.json.JSONObject;
import org.junit.jupiter.api.Test;

public class JSONObjectFactoryTest {

    @Test
    public void generateConstantCommonEventHeader_shouldCreateProperly(){
        JSONObject commonEventHeader = JSONObjectFactory.generateConstantCommonEventHeader();
        assertEquals(9,commonEventHeader.toMap().size());
        assertTrue(commonEventHeader.has(DOMAIN));
        assertTrue(commonEventHeader.has(EVENT_ID));
        assertTrue(commonEventHeader.has(EVENT_TYPE));
        assertTrue(commonEventHeader.has(LAST_EPOCH_MICROSEC));
        assertTrue(commonEventHeader.has(PRIORITY));
        assertTrue(commonEventHeader.has(SEQUENCE));
        assertTrue(commonEventHeader.has(START_EPOCH_MICROSEC));
        assertTrue(commonEventHeader.has(INTERNAL_HEADER_FIELDS));
        assertTrue(commonEventHeader.has(VERSION));
        assertEquals(commonEventHeader.get(DOMAIN),PNF_REGISTRATION);
        assertEquals(commonEventHeader.get(EVENT_TYPE),PNF_REGISTRATION);
        assertEquals(commonEventHeader.get(PRIORITY),PRIORITY_NORMAL);
        assertEquals(commonEventHeader.get(SEQUENCE),SEQUENCE_NUMBER);
        assertEquals(commonEventHeader.get(VERSION),VERSION_NUMBER);
    }

    @Test
    public void generateConstantOtherFields_shouldCreateProperly(){
        JSONObject otherFields = JSONObjectFactory.generateConstantOtherFields();
        assertEquals(3,otherFields.toMap().size());
        assertTrue(otherFields.has(OTHER_FIELDS_VERSION));
        assertEquals(otherFields.get(OTHER_FIELDS_VERSION),OTHER_FIELDS_VERSION_VALUE);
        assertTrue(otherFields.has(PNF_LAST_SERVICE_DATE));
        assertTrue(otherFields.has(PNF_MANUFACTURE_DATE));
    }

    @Test
    public void generateEventId_shouldCreateProperly(){
        String eventId = JSONObjectFactory.generateEventId();
        assertTrue(eventId.startsWith("registration_"));
    }

}
