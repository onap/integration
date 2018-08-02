package org.onap.pnfsimulator.message;

import static org.onap.pnfsimulator.message.MessageConstants.COMMON_EVENT_HEADER;
import static org.onap.pnfsimulator.message.MessageConstants.DOMAIN;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT_ID;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT_TYPE;
import static org.onap.pnfsimulator.message.MessageConstants.INTERNAL_HEADER_FIELDS;
import static org.onap.pnfsimulator.message.MessageConstants.LAST_EPOCH_MICROSEC;
import static org.onap.pnfsimulator.message.MessageConstants.OTHER_FIELDS;
import static org.onap.pnfsimulator.message.MessageConstants.OTHER_FIELDS_VERSION;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_LAST_SERVICE_DATE;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_MANUFACTURE_DATE;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_PREFIX;
import static org.onap.pnfsimulator.message.MessageConstants.PRIORITY;
import static org.onap.pnfsimulator.message.MessageConstants.SEQUENCE;
import static org.onap.pnfsimulator.message.MessageConstants.START_EPOCH_MICROSEC;
import static org.onap.pnfsimulator.message.MessageConstants.VERSION;

import java.util.Map;
import java.util.UUID;
import org.json.JSONObject;

public class MessageProvider {

    public JSONObject createMessage(JSONObject params) {

        if (params == null) {
            throw new IllegalArgumentException("Params object cannot be null");
        }

        Map<String, Object> paramsMap = params.toMap();
        JSONObject root = new JSONObject();
        JSONObject commonEventHeader = generateConstantCommonEventHeader();
        JSONObject otherFields = generateConstantOtherFields();

        paramsMap.forEach((key, value) -> {

            if (key.startsWith(PNF_PREFIX)) {
                otherFields.put(key, value);
            } else {
                commonEventHeader.put(key, value);
            }
        });

        JSONObject event = new JSONObject();
        event.put(COMMON_EVENT_HEADER, commonEventHeader);
        event.put(OTHER_FIELDS, otherFields);
        root.put(EVENT, event);
        return root;
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
        otherFields.put(PNF_LAST_SERVICE_DATE, System.currentTimeMillis());
        otherFields.put(PNF_MANUFACTURE_DATE, System.currentTimeMillis());

        return otherFields;
    }
}
