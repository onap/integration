package org.onap.pnfsimulator.message;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.onap.pnfsimulator.message.MessageConstants.COMMON_EVENT_HEADER;
import static org.onap.pnfsimulator.message.MessageConstants.DOMAIN;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT_ID;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT_TYPE;
import static org.onap.pnfsimulator.message.MessageConstants.INTERNAL_HEADER_FIELDS;
import static org.onap.pnfsimulator.message.MessageConstants.LAST_EPOCH_MICROSEC;
import static org.onap.pnfsimulator.message.MessageConstants.OTHER_FIELDS;
import static org.onap.pnfsimulator.message.MessageConstants.OTHER_FIELDS_VERSION;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_LAST_SERVICE_DATE;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_MANUFACTURE_DATE;
import static org.onap.pnfsimulator.message.MessageConstants.PRIORITY;
import static org.onap.pnfsimulator.message.MessageConstants.SEQUENCE;
import static org.onap.pnfsimulator.message.MessageConstants.START_EPOCH_MICROSEC;
import static org.onap.pnfsimulator.message.MessageConstants.VERSION;

import java.util.UUID;
import org.json.JSONObject;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class MessageProviderTest {

    private static final String testParamsJson =
        "{\"key1\": \"val1\",\"key2\": \"val2\",\"pnfKey3\": \"pnfVal3\",\"key4\": \"val4\"}";

    private static MessageProvider messageProvider;

    @BeforeAll
    public static void setup() {
        messageProvider = MessageProvider.getInstance();
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

        JSONObject commonEventHeader = message.getJSONObject(COMMON_EVENT_HEADER);
        JSONObject otherFields = message.getJSONObject(OTHER_FIELDS);

        JSONObject expectedCommonEventHeader = generateConstantCommonEventHeader();
        JSONObject expectedOtherFields = generateConstantOtherFields();

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

        JSONObject commonEventHeader = message.getJSONObject(COMMON_EVENT_HEADER);
        JSONObject otherFields = message.getJSONObject(OTHER_FIELDS);

        assertEquals("pnfVal3", otherFields.getString("pnfKey3"));
        assertEquals("val1", commonEventHeader.getString("key1"));
        assertEquals("val2", commonEventHeader.getString("key2"));
        assertEquals("val4", commonEventHeader.getString("key4"));
    }


    private JSONObject generateConstantCommonEventHeader() {

        JSONObject commonEventHeader = new JSONObject();
        long timestamp = System.currentTimeMillis();

        commonEventHeader.put(DOMAIN, "other");
        commonEventHeader.put(EVENT_ID, UUID.randomUUID() + "-reg");
        commonEventHeader.put(EVENT_TYPE, "pnfRegistration");
        commonEventHeader.put(LAST_EPOCH_MICROSEC, timestamp);
        commonEventHeader.put(PRIORITY, "Normal");
        commonEventHeader.put(SEQUENCE, 0);
        commonEventHeader.put(START_EPOCH_MICROSEC, timestamp);
        commonEventHeader.put(INTERNAL_HEADER_FIELDS, new JSONObject());
        commonEventHeader.put(VERSION, 3);

        return commonEventHeader;
    }

    private JSONObject generateConstantOtherFields() {
        JSONObject otherFields = new JSONObject();

        otherFields.put(OTHER_FIELDS_VERSION, 1);
        otherFields.put(PNF_LAST_SERVICE_DATE, 1517206400);
        otherFields.put(PNF_MANUFACTURE_DATE, 1516406400);

        return otherFields;
    }

}
