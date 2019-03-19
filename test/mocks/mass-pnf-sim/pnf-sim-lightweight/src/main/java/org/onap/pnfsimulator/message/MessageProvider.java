/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================ Copyright (C)
 * 2018 NOKIA Intellectual Property. All rights reserved.
 * ================================================================================ Licensed under
 * the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License. ============LICENSE_END=========================================================
 */

package org.onap.pnfsimulator.message;

import static org.onap.pnfsimulator.message.MessageConstants.COMMON_EVENT_HEADER;
import static org.onap.pnfsimulator.message.MessageConstants.DOMAIN;
import static org.onap.pnfsimulator.message.MessageConstants.DOMAIN_NOTIFICATION;
import static org.onap.pnfsimulator.message.MessageConstants.DOMAIN_PNF_REGISTRATION;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT_TYPE;
import static org.onap.pnfsimulator.message.MessageConstants.NOTIFICATION_FIELDS;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_REGISTRATION_FIELDS;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import org.json.JSONArray;
import org.json.JSONObject;

public class MessageProvider {

    public JSONObject createMessage(JSONObject commonEventHeaderParams, Optional<JSONObject> pnfRegistrationParams,
            Optional<JSONObject> notificationParams) {

        if (!pnfRegistrationParams.isPresent() && !notificationParams.isPresent()) {
            throw new IllegalArgumentException(
                    "Both PNF registration and notification parameters objects are not present");
        }
        JSONObject event = new JSONObject();

        JSONObject commonEventHeader = JSONObjectFactory.generateConstantCommonEventHeader();
        Map<String, Object> commonEventHeaderFields = commonEventHeaderParams.toMap();
        commonEventHeaderFields.forEach((key, value) -> {
            commonEventHeader.put(key, value);
        });

        JSONObject pnfRegistrationFields = JSONObjectFactory.generatePnfRegistrationFields();
        pnfRegistrationParams.ifPresent(jsonObject -> {
            copyParametersToFields(jsonObject.toMap(), pnfRegistrationFields);
            commonEventHeader.put(DOMAIN, DOMAIN_PNF_REGISTRATION);
            commonEventHeader.put(EVENT_TYPE, DOMAIN_PNF_REGISTRATION);
            event.put(PNF_REGISTRATION_FIELDS, pnfRegistrationFields);
        });

        JSONObject notificationFields = JSONObjectFactory.generateNotificationFields();
        notificationParams.ifPresent(jsonObject -> {
            copyParametersToFields(jsonObject.toMap(), notificationFields);
            commonEventHeader.put(DOMAIN, DOMAIN_NOTIFICATION);
            event.put(NOTIFICATION_FIELDS, notificationFields);
        });

        event.put(COMMON_EVENT_HEADER, commonEventHeader);
        JSONObject root = new JSONObject();
        root.put(EVENT, event);
        return root;
    }

    private void copyParametersToFields(Map<String, Object> paramersMap, JSONObject fieldsJsonObject) {
        paramersMap.forEach((key, value) -> {
            fieldsJsonObject.put(key, value);
        });
    }

    public JSONObject createOneVes(JSONObject commonEventHeaderParams, Optional<JSONObject> pnfRegistrationParams,
            Optional<JSONObject> notificationParams, String url, String fileName) {


        if (!pnfRegistrationParams.isPresent() && !notificationParams.isPresent()) {
            throw new IllegalArgumentException(
                    "Both PNF registration and notification parameters objects are not present");
        }
        JSONObject event = new JSONObject();

        JSONObject commonEventHeader = JSONObjectFactory.generateConstantCommonEventHeader();
        Map<String, Object> commonEventHeaderFields = commonEventHeaderParams.toMap();
        commonEventHeaderFields.forEach((key, value) -> {
            commonEventHeader.put(key, value);
        });

        JSONObject pnfRegistrationFields = JSONObjectFactory.generatePnfRegistrationFields();
        pnfRegistrationParams.ifPresent(jsonObject -> {
            copyParametersToFields(jsonObject.toMap(), pnfRegistrationFields);
            commonEventHeader.put(DOMAIN, DOMAIN_PNF_REGISTRATION);
            commonEventHeader.put(EVENT_TYPE, DOMAIN_PNF_REGISTRATION);
            event.put(PNF_REGISTRATION_FIELDS, pnfRegistrationFields);
        });

        JSONObject notificationFields = JSONObjectFactory.generateNotificationFields();

        Map hashMap = new HashMap();
        hashMap.put("location", "LOCATION_DUMMY");
        hashMap.put("fileFormatType", "org.3GPP.32.435#measCollec");
        hashMap.put("fileFormatVersion", "V10");
        hashMap.put("compression", "gzip");


        JSONObject jsonHashMap = new JSONObject();
        jsonHashMap.put("hashmap", jsonHashMap);

        JSONArray jsonArrayOfNamedHashMap = new JSONArray();
        jsonArrayOfNamedHashMap.put(jsonHashMap);



        // // notification.put("name", "NAME_DUMMY");
        // JSONObject notification = new JSONObject();
        //
        // notificationParams.ifPresent(jsonObject -> {
        // copyParametersToFields(notification, notificationFields);
        // commonEventHeader.put(DOMAIN, DOMAIN_NOTIFICATION);
        // event.put(NOTIFICATION_FIELDS, notificationFields);
        // });


        // notificationParams.ifPresent(jsonObject -> {
        // copyParametersToFields(jsonObject.toMap(), notificationFields);
        // commonEventHeader.put(DOMAIN, DOMAIN_NOTIFICATION);
        // event.put(NOTIFICATION_FIELDS, notificationFields);
        // });

        event.put(COMMON_EVENT_HEADER, commonEventHeader);
        JSONObject root = new JSONObject();
        root.put(EVENT, event);
        return root;

    }

    public JSONObject createOneVesEvent(String xnfUrl, String fileName) {

        String notificationFields;
        JSONObject nof = new JSONObject();

        nof.put("notificationFieldsVersion", "2.0");

        nof.put("changeType", "FileReady");
        nof.put("changeIdentifier", "PM_MEAS_FILES");

        JSONObject hm = new JSONObject();
        hm.put("location", xnfUrl.concat(fileName));
        hm.put("fileFormatType", "org.3GPP.32.435#measCollec");
        hm.put("fileFormatVersion", "V10");
        hm.put("compression", "gzip");

        JSONObject aonh = new JSONObject();
        aonh.put("name", fileName);

        aonh.put("hashMap", hm);

        nof.put("arrayOfNamedHashMap", aonh);

        String nofString = nof.toString();

        JSONObject ceh = new JSONObject(); // commonEventHandler
        ceh.put("startEpochMicrosec", "1551865758690");
        ceh.put("sourceId", "val13");
        ceh.put("eventId", "registration_51865758");
        ceh.put("nfcNamingCode", "oam");
        ceh.put("priority", "Normal");
        ceh.put("version", "4.0.1");
        ceh.put("reportingEntityName", "NOK6061ZW3");
        ceh.put("sequence", "0");
        ceh.put("domain", "notification");
        ceh.put("lastEpochMicrosec", "1551865758690");
        ceh.put("eventName", "pnfRegistration_Nokia_5gDu");
        ceh.put("vesEventListenerVersion", "7.0.1");
        ceh.put("sourceName", "NOK6061ZW3");
        ceh.put("nfNamingCode", "gNB");

        JSONObject ihf = new JSONObject(); // internalHeaderFields
        ceh.put("internalHeaderFields", ihf);

        JSONObject event = new JSONObject();
        event.put("commonEventHeader", ceh);
        event.put("notificationFields", nof);

        System.out.println("event: ");
        System.out.println(event.toString());

        return event;

     // @formatter:off
        /*
        {
            "commonEventHeader": {                          <== "ceh"
                "startEpochMicrosec": "1551865758690",
                "sourceId": "val13",
                "eventId": "registration_51865758",
                "nfcNamingCode": "oam",
                "internalHeaderFields": {},                 <== "ihf"
                "priority": "Normal",
                "version": "4.0.1",
                "reportingEntityName": "NOK6061ZW3",
                "sequence": "0",
                "domain": "notification",
                "lastEpochMicrosec": "1551865758690",
                "eventName": "pnfRegistration_Nokia_5gDu",
                "vesEventListenerVersion": "7.0.1",
                "sourceName": "NOK6061ZW3",
                "nfNamingCode": "gNB"
            },
            "notificationFields": {                         <== "nof"
                "": "",
                "notificationFieldsVersion": "2.0",
                "changeType": "FileReady",
                "changeIdentifier": "PM_MEAS_FILES",
                "arrayOfNamedHashMap": {                    <== "aonh"
                    "name": "A20161224.1030-1045.bin.gz",
                    "hashMap": {                            <== "hm"
                        "location": "ftpes://192.169.0.1:22/ftp/rop/A20161224.1030-1045.bin.gz",
                        "fileFormatType": "org.3GPP.32.435#measCollec",
                        "fileFormatVersion": "V10",
                        "compression": "gzip"
                    }
                }
            }
        }

        */
     // @formatter:on

    }

}
