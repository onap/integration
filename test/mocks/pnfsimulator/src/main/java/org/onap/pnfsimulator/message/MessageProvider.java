/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2018-2019 NOKIA Intellectual Property. All rights reserved.
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

public class MessageProvider {

    public JSONObject createMessageWithNotification(JSONObject commonEventHeaderParams,
                                                    JSONObject notificationParams) {
        return MessageBuilder
                .withCommonEventHeaderParams(commonEventHeaderParams)
                .withNotificationParams(notificationParams)
                .build();
    }

    public JSONObject createMessageWithPnfRegistration(JSONObject commonEventHeaderParams, JSONObject pnfRegistrationParams) {
        return MessageBuilder
                .withCommonEventHeaderParams(commonEventHeaderParams)
                .withPnfRegistrationParams(pnfRegistrationParams)
                .build();
    }

}
