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

import static org.onap.pnfsimulator.message.MessageConstants.COMPRESSION;
import static org.onap.pnfsimulator.message.MessageConstants.COMPRESSION_VALUE;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT_ID;
import static org.onap.pnfsimulator.message.MessageConstants.FILE_FORMAT_TYPE;
import static org.onap.pnfsimulator.message.MessageConstants.FILE_FORMAT_TYPE_VALUE;
import static org.onap.pnfsimulator.message.MessageConstants.FILE_FORMAT_VERSION;
import static org.onap.pnfsimulator.message.MessageConstants.FILE_FORMAT_VERSION_VALUE;
import static org.onap.pnfsimulator.message.MessageConstants.HASH_MAP;
import static org.onap.pnfsimulator.message.MessageConstants.INTERNAL_HEADER_FIELDS;
import static org.onap.pnfsimulator.message.MessageConstants.LAST_EPOCH_MICROSEC;
import static org.onap.pnfsimulator.message.MessageConstants.LOCATION;
import static org.onap.pnfsimulator.message.MessageConstants.NAME;
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
import java.io.File;
import java.util.List;
import java.util.TimeZone;
import org.json.JSONArray;
import org.json.JSONObject;

final class JSONObjectFactory {

    static JSONObject generateConstantCommonEventHeader() {
        JSONObject commonEventHeader = new JSONObject();
        long timestamp = System.currentTimeMillis();
        commonEventHeader.put(EVENT_ID, generateEventId());
        commonEventHeader.put(TIME_ZONE_OFFSET, generateTimeZone(timestamp));
        commonEventHeader.put(LAST_EPOCH_MICROSEC, timestamp);
        commonEventHeader.put(PRIORITY, PRIORITY_NORMAL);
        commonEventHeader.put(SEQUENCE, SEQUENCE_NUMBER);
        commonEventHeader.put(START_EPOCH_MICROSEC, timestamp);
        commonEventHeader.put(INTERNAL_HEADER_FIELDS, new JSONObject());
        commonEventHeader.put(VERSION, VERSION_NUMBER);
        commonEventHeader.put(VES_EVENT_LISTENER_VERSION, VES_EVENT_LISTENER_VERSION_NUMBER);
        String absPath = new File("").getAbsolutePath();
        String nodeName = absPath.substring(absPath.lastIndexOf(File.separator)+1);
        commonEventHeader.put(SOURCE_NAME, nodeName);
        commonEventHeader.put(REPORTING_ENTITY_NAME, nodeName);
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

    static JSONArray generateArrayOfNamedHashMap(List<String> fileList, String xnfUrl) {
        JSONArray arrayOfNamedHashMap = new JSONArray();

        for (String fileName : fileList) {
            JSONObject namedHashMap = new JSONObject();
            namedHashMap.put(NAME, fileName);

            JSONObject hashMap = new JSONObject();
            hashMap.put(FILE_FORMAT_TYPE, FILE_FORMAT_TYPE_VALUE);
            hashMap.put(LOCATION, xnfUrl.concat(fileName));
            hashMap.put(FILE_FORMAT_VERSION, FILE_FORMAT_VERSION_VALUE);
            hashMap.put(COMPRESSION, COMPRESSION_VALUE);
            namedHashMap.put(HASH_MAP, hashMap);

            arrayOfNamedHashMap.put(namedHashMap);
        }


        return arrayOfNamedHashMap;
    }


    static String generateEventId() {
        String timeAsString = String.valueOf(System.currentTimeMillis());
        return String.format("FileReady_%s", timeAsString);
    }

    static String generateTimeZone(long timestamp) {
        TimeZone timeZone = TimeZone.getDefault();
        int offsetInMillis = timeZone.getOffset(timestamp);
        String offsetHHMM = String.format("%02d:%02d", Math.abs(offsetInMillis / 3600000),
                Math.abs((offsetInMillis / 60000) % 60));
        return ("UTC" + (offsetInMillis >= 0 ? "+" : "-") + offsetHHMM);
    }

    private JSONObjectFactory() {

    }

}
