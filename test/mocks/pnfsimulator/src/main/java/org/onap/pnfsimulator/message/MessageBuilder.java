/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2019 NOKIA Intellectual Property. All rights reserved.
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

import org.json.JSONObject;

import static org.onap.pnfsimulator.message.MessageConstants.COMMON_EVENT_HEADER;
import static org.onap.pnfsimulator.message.MessageConstants.DOMAIN;
import static org.onap.pnfsimulator.message.MessageConstants.DOMAIN_NOTIFICATION;
import static org.onap.pnfsimulator.message.MessageConstants.DOMAIN_PNF_REGISTRATION;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT;
import static org.onap.pnfsimulator.message.MessageConstants.EVENT_TYPE;
import static org.onap.pnfsimulator.message.MessageConstants.NOTIFICATION_FIELDS;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_REGISTRATION_FIELDS;

public final class MessageBuilder {
    private JSONObject root;
    private JSONObject event;
    private JSONObject commonEventHeader;

    private MessageBuilder() {
    }

    public static MessageBuilder withCommonEventHeaderParams(JSONObject commonEventHeaderParams) {
        MessageBuilder builder = new MessageBuilder();
        builder.initializeBuilder(commonEventHeaderParams);
        return builder;
    }

    public MessageBuilder withNotificationParams(JSONObject notificationParams) {
        JSONObject notificationFields = JSONObjectFactory.generateNotificationFields();
        merge(notificationParams, notificationFields);
        commonEventHeader.put(DOMAIN, DOMAIN_NOTIFICATION);
        event.put(NOTIFICATION_FIELDS, notificationFields);
        return this;
    }

    public MessageBuilder withPnfRegistrationParams(JSONObject pnfRegistrationParams) {
        JSONObject pnfRegistrationFields = JSONObjectFactory.generatePnfRegistrationFields();
        merge(pnfRegistrationParams, pnfRegistrationFields);
        commonEventHeader.put(DOMAIN, DOMAIN_PNF_REGISTRATION);
        commonEventHeader.put(EVENT_TYPE, DOMAIN_PNF_REGISTRATION);
        event.put(PNF_REGISTRATION_FIELDS, pnfRegistrationFields);
        return this;
    }

    public JSONObject build() {
        return root;
    }

    private void initializeBuilder(JSONObject commonEventHeaderParams) {
        root = new JSONObject();
        event = new JSONObject();
        commonEventHeader = JSONObjectFactory.generateConstantCommonEventHeader();
        commonEventHeaderParams.toMap().forEach(commonEventHeader::put);
        event.put(COMMON_EVENT_HEADER, commonEventHeader);
        root.put(EVENT, event);
    }

    private void merge(JSONObject source, JSONObject destination) {
        source.toMap().forEach(destination::put);
    }
}
