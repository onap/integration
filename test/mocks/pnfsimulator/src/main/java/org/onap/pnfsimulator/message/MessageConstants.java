package org.onap.pnfsimulator.message;

public final class MessageConstants {

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
    static final String OTHER_FIELDS_VERSION = "otherFieldsVersion";
    static final String PNF_LAST_SERVICE_DATE = "pnfLastServiceDate";
    static final String PNF_MANUFACTURE_DATE = "pnfManufactureDate";

    static final String SIMULATOR_PARAMS_CONTAINER = "simulatorParams";
    static final String MESSAGE_PARAMS_CONTAINER = "messageParams";

    // mandatory used in json file, but not in java logic
    //public static final String PNF_OAM_IPV4_ADDRESS = "pnfOamIpv4Address";
    //public static final String PNF_OAM_IPV6_ADDRESS = "pnfOamIpv6Address";
    //public static final String PNF_SERIAL_NUMBER = "pnfSerialNumber";
    //public static final String PNF_VENDOR_NAME = "pnfVendorName";
    static final String VES_SERVER_URL = "vesServerUrl";
    static final String PNF_PREFIX = "pnf";
    static final String COMMON_EVENT_HEADER = "commonEventHeader";
    static final String OTHER_FIELDS = "otherFields";
    static final String TEST_DURATION = "testDuration";
    static final String MESSAGE_INTERVAL = "messageInterval";

    //===============================================================
    //constant values
    static final String PNF_REGISTRATION ="pnfRegistration";
    static final String PRIORITY_NORMAL = "Normal";
    static final float VERSION_NUMBER = 3.0f;
    static final int SEQUENCE_NUMBER = 0;
    static final int OTHER_FIELDS_VERSION_VALUE = 1;

    private MessageConstants() {
    }

}
