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

import static org.onap.pnfsimulator.message.MessageConstants.COMMON_EVENT_HEADER;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_PREFIX;
import static org.onap.pnfsimulator.message.MessageConstants.NOTIFICATION_FIELDS;
import static org.onap.pnfsimulator.message.MessageConstants.NOTIFICATION_FIELDS_VERSION;
import static org.onap.pnfsimulator.message.MessageConstants.NOTIFICATION_FIELDS_VERSION_VALUE;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_REGISTRATION_FIELDS;

import java.util.Map;
import org.json.JSONObject;

public class MessageProvider {

    public JSONObject createMessage(JSONObject pnfRegistrationParams, JSONObject notificationParams) {

        if (pnfRegistrationParams == null && notificationParams == null) {
            throw new IllegalArgumentException("Both PNF registration and notification parameters objects not present");
        }

        //TODO
        Map<String, Object> paramsMap = pnfRegistrationParams.toMap();
        JSONObject root = new JSONObject();
        JSONObject commonEventHeader = JSONObjectFactory.generateConstantCommonEventHeader();
        JSONObject pnfRegistrationFields = JSONObjectFactory.generatePnfRegistrationFields();

        paramsMap.forEach((key, value) -> {

            if (key.startsWith(PNF_PREFIX)) {
                pnfRegistrationFields.put(key.substring(PNF_PREFIX.length()), value);
            } else {
                commonEventHeader.put(key, value);
            }
        });

        if (notificationParams != null) {
            notificationParams.put(NOTIFICATION_FIELDS_VERSION, NOTIFICATION_FIELDS_VERSION_VALUE);
        }

        JSONObject event = new JSONObject();
        event.put(COMMON_EVENT_HEADER, commonEventHeader);
        event.put(PNF_REGISTRATION_FIELDS, pnfRegistrationFields);
        event.put(NOTIFICATION_FIELDS,notificationParams);
        root.put(EVENT, event);
        return root;
    }

}
