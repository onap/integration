package org.onap.pnfsimulator.message;

import static org.onap.pnfsimulator.message.MessageConstants.*;

import org.json.JSONObject;

final class JSONObjectFactory {

    static JSONObject generateConstantCommonEventHeader() {
        JSONObject commonEventHeader = new JSONObject();
        long timestamp = System.currentTimeMillis();
        commonEventHeader.put(DOMAIN, PNF_REGISTRATION);
        commonEventHeader.put(EVENT_ID, generateEventId());
        commonEventHeader.put(EVENT_TYPE, PNF_REGISTRATION);
        commonEventHeader.put(LAST_EPOCH_MICROSEC, timestamp);
        commonEventHeader.put(PRIORITY, PRIORITY_NORMAL);
        commonEventHeader.put(SEQUENCE, SEQUENCE_NUMBER);
        commonEventHeader.put(START_EPOCH_MICROSEC, timestamp);
        commonEventHeader.put(INTERNAL_HEADER_FIELDS, new JSONObject());
        commonEventHeader.put(VERSION, VERSION_NUMBER);
        commonEventHeader.put(VES_EVENT_LISTENER_VERSION, VES_EVENT_LISTENER_VERSION_NUMBER);
        return commonEventHeader;
    }

    static JSONObject generatePnfRegistrationFields() {
        JSONObject pnfRegistrationFields = new JSONObject();
        pnfRegistrationFields.put(PNF_REGISTRATION_FIELDS_VERSION, PNF_REGISTRATION_FIELDS_VERSION_VALUE);
        pnfRegistrationFields.put(PNF_LAST_SERVICE_DATE, String.valueOf(System.currentTimeMillis()));
        pnfRegistrationFields.put(PNF_MANUFACTURE_DATE, String.valueOf(System.currentTimeMillis()));
        return pnfRegistrationFields;
    }

    static String generateEventId() {
        String timeAsString = String.valueOf(System.currentTimeMillis());
        return String.format("registration_%s",
            timeAsString.substring(timeAsString.length() - 11, timeAsString.length() - 3));
    }

    private JSONObjectFactory(){

    }

}
