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
        assertEquals(10,commonEventHeader.toMap().size());
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
        assertTrue(eventId.startsWith("registration_"));
    }

}
