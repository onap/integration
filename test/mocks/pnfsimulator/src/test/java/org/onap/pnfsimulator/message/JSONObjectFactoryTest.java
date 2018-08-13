package org.onap.pnfsimulator.message;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.onap.pnfsimulator.message.MessageConstants.*;

import org.json.JSONObject;
import org.junit.jupiter.api.Test;

public class JSONObjectFactoryTest {

    @Test
    public void generateConstantCommonEventHeader(){
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
    public void generateConstantOtherFields(){
        JSONObject otherFields = JSONObjectFactory.generateConstantOtherFields();
        assertEquals(3,otherFields.toMap().size());
        assertTrue(otherFields.has(OTHER_FIELDS_VERSION));
        assertEquals(otherFields.get(OTHER_FIELDS_VERSION),OTHER_FIELDS_VERSION_VALUE);
        assertTrue(otherFields.has(PNF_LAST_SERVICE_DATE));
        assertTrue(otherFields.has(PNF_MANUFACTURE_DATE));
    }

    @Test
    public void generateEventId(){
        String eventId = JSONObjectFactory.generateEventId();
        assertTrue(eventId.startsWith("registration_"));
    }

}
