/*-
 * ============LICENSE_START=======================================================
 * org.onap.integration
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
import static org.onap.pnfsimulator.message.MessageConstants.DOMAIN;
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
import static org.onap.pnfsimulator.message.MessageConstants.EVENT;

import java.util.Map;
import java.util.UUID;

import com.google.common.base.Preconditions;
import org.json.JSONObject;

public class MessageProvider {

    private static MessageProvider instance;

    public static MessageProvider getInstance() {
        if (instance == null) {
            instance = new MessageProvider();
        }
        return instance;
    }

    public JSONObject createMessage(JSONObject params) {

        Preconditions.checkArgument(params != null, "Params object cannot be null");
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
        commonEventHeader.put("functionalRole", "test_rola");

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
