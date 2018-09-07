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
import java.util.Optional;
import org.json.JSONObject;

public class MessageProvider {

    public JSONObject createMessage(Optional<JSONObject> pnfRegistrationParams, Optional<JSONObject> notificationParams) {

        if (!pnfRegistrationParams.isPresent() && !notificationParams.isPresent()) {
            throw new IllegalArgumentException("Both PNF registration and notification parameters objects not present");
        }

        JSONObject root = new JSONObject();
        JSONObject event = new JSONObject();

        JSONObject commonEventHeader = JSONObjectFactory.generateConstantCommonEventHeader();
        JSONObject pnfRegistrationFields = JSONObjectFactory.generatePnfRegistrationFields();

        pnfRegistrationParams.ifPresent(jsonObject -> {
            Map<String, Object> paramsMap = jsonObject.toMap();
            paramsMap.forEach((key, value) -> {

                if (key.startsWith(PNF_PREFIX)) {
                    pnfRegistrationFields.put(key.substring(PNF_PREFIX.length()), value);
                } else {
                    commonEventHeader.put(key, value);
                }
            });
            event.put(COMMON_EVENT_HEADER, commonEventHeader);
            event.put(PNF_REGISTRATION_FIELDS, pnfRegistrationFields);
        });


        notificationParams.ifPresent(jsonObject -> {
            jsonObject.put(NOTIFICATION_FIELDS_VERSION, NOTIFICATION_FIELDS_VERSION_VALUE);
            event.put(NOTIFICATION_FIELDS,notificationParams);
        });

        root.put(EVENT, event);
        return root;
    }

}
