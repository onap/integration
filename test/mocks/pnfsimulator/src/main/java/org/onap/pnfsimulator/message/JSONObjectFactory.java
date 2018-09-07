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
import static org.onap.pnfsimulator.message.MessageConstants.SEQUENCE;
import static org.onap.pnfsimulator.message.MessageConstants.SEQUENCE_NUMBER;
import static org.onap.pnfsimulator.message.MessageConstants.START_EPOCH_MICROSEC;
import static org.onap.pnfsimulator.message.MessageConstants.VERSION;
import static org.onap.pnfsimulator.message.MessageConstants.VERSION_NUMBER;
import static org.onap.pnfsimulator.message.MessageConstants.VES_EVENT_LISTENER_VERSION;
import static org.onap.pnfsimulator.message.MessageConstants.VES_EVENT_LISTENER_VERSION_NUMBER;

import org.json.JSONObject;

final class JSONObjectFactory {

    static JSONObject generateConstantCommonEventHeader() {
        JSONObject commonEventHeader = new JSONObject();
        long timestamp = System.currentTimeMillis();
        commonEventHeader.put(EVENT_ID, generateEventId());
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

    static JSONObject generateNotificationFields() {
        JSONObject notificationFields = new JSONObject();
        notificationFields.put(NOTIFICATION_FIELDS_VERSION, NOTIFICATION_FIELDS_VERSION_VALUE);
        return notificationFields;
    }


    static String generateEventId() {
        String timeAsString = String.valueOf(System.currentTimeMillis());
        return String.format("registration_%s",
            timeAsString.substring(timeAsString.length() - 11, timeAsString.length() - 3));
    }

    private JSONObjectFactory() {

    }

}
