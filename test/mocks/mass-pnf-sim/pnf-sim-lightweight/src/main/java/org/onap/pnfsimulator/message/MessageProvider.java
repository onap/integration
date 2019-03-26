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

import static org.onap.pnfsimulator.message.MessageConstants.ARRAY_OF_NAMED_HASH_MAP;
import static org.onap.pnfsimulator.message.MessageConstants.COMMON_EVENT_HEADER;
import static org.onap.pnfsimulator.message.MessageConstants.DOMAIN;
import static org.onap.pnfsimulator.message.MessageConstants.DOMAIN_NOTIFICATION;
import static org.onap.pnfsimulator.message.MessageConstants.DOMAIN_PNF_REGISTRATION;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT_TYPE;
import static org.onap.pnfsimulator.message.MessageConstants.NOTIFICATION_FIELDS;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_REGISTRATION_FIELDS;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.json.JSONArray;
import org.json.JSONObject;

public class MessageProvider {

    public JSONObject createMessage(JSONObject commonEventHeaderParams, Optional<JSONObject> pnfRegistrationParams,
            Optional<JSONObject> notificationParams) {
        List<String> emptyList = new ArrayList<>();
        String emptyString = "";
        return createMessage(commonEventHeaderParams, pnfRegistrationParams, notificationParams, emptyList, emptyString);
    }

    public JSONObject createMessage(JSONObject commonEventHeaderParams, Optional<JSONObject> pnfRegistrationParams,
            Optional<JSONObject> notificationParams, List<String> fileList, String xnfUrl) {

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
            JSONArray arrayOfNamedHashMap = JSONObjectFactory.generateArrayOfNamedHashMap(fileList, xnfUrl);
            notificationFields.put(ARRAY_OF_NAMED_HASH_MAP, arrayOfNamedHashMap);
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
}
