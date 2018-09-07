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

public final class MessageConstants {

    public static final String SIMULATOR_PARAMS = "simulatorParams";
    public static final String PNF_REGISTRATION_PARAMS = "pnfRegistrationParams";
    public static final String NOTIFICATION_PARAMS = "notificationParams";

    static final String COMMON_EVENT_HEADER = "commonEventHeader";
    static final String PNF_REGISTRATION_FIELDS = "pnfRegistrationFields";
    static final String NOTIFICATION_FIELDS = "notificationFields";

    static final String EVENT = "event";
    static final String DOMAIN = "domain";
    static final String EVENT_ID = "eventId";
    static final String EVENT_TYPE = "eventType";
    static final String LAST_EPOCH_MICROSEC = "lastEpochMicrosec";
    static final String PRIORITY = "priority";
    static final String SEQUENCE = "sequence";
    static final String START_EPOCH_MICROSEC = "startEpochMicrosec";
    static final String INTERNAL_HEADER_FIELDS = "internalHeaderFields";
    static final String VERSION = "version";
    static final String PNF_REGISTRATION_FIELDS_VERSION = "pnfRegistrationFieldsVersion";
    static final String PNF_LAST_SERVICE_DATE = "lastServiceDate";
    static final String PNF_MANUFACTURE_DATE = "manufactureDate";
    static final String VES_EVENT_LISTENER_VERSION = "vesEventListenerVersion";

    // mandatory used in json file, but not in java logic
    //public static final String PNF_OAM_IPV4_ADDRESS = "pnfOamIpv4Address";
    //public static final String PNF_OAM_IPV6_ADDRESS = "pnfOamIpv6Address";
    //public static final String PNF_SERIAL_NUMBER = "pnfSerialNumber";
    //public static final String PNF_VENDOR_NAME = "pnfVendorName";
    public static final String VES_SERVER_URL = "vesServerUrl";
    public static final String TEST_DURATION = "testDuration";
    public static final String MESSAGE_INTERVAL = "messageInterval";
    static final String PNF_PREFIX = "pnf_";



    //=============================================================================================
    // Notifications
    static final String NOTIFICATION_FIELDS_VERSION = "notificationFieldsVersion";
    static final String NOTIFICATION_FIELDS_VERSION_VALUE = "2.0";

    //=============================================================================================
    //constant values
    static final String PNF_REGISTRATION ="pnfRegistration";
    static final String PRIORITY_NORMAL = "Normal";
    static final String VERSION_NUMBER = "4.0.1";
    static final String VES_EVENT_LISTENER_VERSION_NUMBER = "7.0.1";
    static final String PNF_REGISTRATION_FIELDS_VERSION_VALUE = "2.0";
    static final int SEQUENCE_NUMBER = 0;

    private MessageConstants() {
    }

}
