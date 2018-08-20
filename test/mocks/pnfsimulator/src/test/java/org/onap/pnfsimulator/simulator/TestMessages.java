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

package org.onap.pnfsimulator.simulator;

import org.json.JSONObject;

final class TestMessages {

    static final JSONObject VALID_SIMULATOR_PARAMS = new JSONObject(
        "{\n" +
            "    \"vesServerUrl\": \"http://10.42.111.42:8080/eventListener/v5\",\n" +
            "    \"testDuration\": \"10\",\n" +
            "    \"messageInterval\": \"1\"\n" +
            "}");


    static final JSONObject VALID_MESSAGE_PARAMS = new JSONObject(
        "{\n"
            + "    \"pnf_serialNumber\": \"6061ZW3\",\n"
            + "    \"pnf_vendorName\": \"Nokia\",\n"
            + "    \"pnf_oamV4IpAddress\": \"val3\",\n"
            + "    \"pnf_oamV6IpAddress\": \"val4\",\n"
            + "    \"pnf_unitFamily\": \"BBU\",\n"
            + "    \"pnf_modelNumber\": \"val6\",\n"
            + "    \"pnf_softwareVersion\": \"val7\",\n"
            + "    \"pnf_unitType\": \"val8\",\n"
            + "    \"eventName\": \"pnfRegistration_Nokia_5gDu\",\n"
            + "    \"nfNamingCode\": \"gNB\",\n"
            + "    \"nfcNamingCode\": \"oam\",\n"
            + "    \"sourceName\": \"NOK6061ZW3\",\n"
            + "    \"sourceId\": \"val13\",\n"
            + "    \"reportingEntityName\": \"NOK6061ZW3\"\n"
            + "  }");

    static final JSONObject INVALID_SIMULATOR_PARAMS = new JSONObject(
        "{\n" +
            "    \"vesServerUrl\": \"http://10.42.111.42:8080/eventListener/v5\",\n" +
            "    \"messageInterval\": \"1\"\n" +
            "}");


    static final JSONObject INVALID_MESSAGE_PARAMS_1 = new JSONObject(
        "{\n" +
            "    \"pnfSerialNumber\": \"val1\",\n" +
            "    \"pnfVendorName\": \"val2\",\n" +
            "    \"pnfFamily\": \"val5\",\n" +
            "    \"pnfModelNumber\": \"val6\",\n" +
            "    \"pnfSoftwareVersion\": \"val7\",\n" +
            "    \"pnfType\": \"val8\",\n" +
            "    \"eventName\": \"val9\",\n" +
            "    \"nfNamingCode\": \"val10\",\n" +
            "    \"nfcNamingCode\": \"val11\",\n" +
            "    \"sourceName\": \"val12\",\n" +
            "    \"sourceId\": \"val13\",\n" +
            "    \"reportingEntityName\": \"val14\"\n" +
            "}");

    static final JSONObject INVALID_MESSAGE_PARAMS_2 = new JSONObject(
        "{\n" +
            "    \"pnfVendorName\": \"val2\",\n" +
            "    \"pnfOamIpv4Address\": \"val3\",\n" +
            "    \"pnfOamIpv6Address\": \"val4\",\n" +
            "    \"pnfFamily\": \"val5\",\n" +
            "    \"pnfModelNumber\": \"val6\",\n" +
            "    \"pnfSoftwareVersion\": \"val7\",\n" +
            "    \"pnfType\": \"val8\",\n" +
            "    \"eventName\": \"val9\",\n" +
            "    \"nfNamingCode\": \"val10\",\n" +
            "    \"nfcNamingCode\": \"val11\",\n" +
            "    \"sourceName\": \"val12\",\n" +
            "    \"sourceId\": \"val13\",\n" +
            "    \"reportingEntityName\": \"val14\"\n" +
            "}");

    static final JSONObject INVALID_MESSAGE_PARAMS_3 = new JSONObject(
        "{\n" +
            "    \"pnfSerialNumber\": \"val1\",\n" +
            "    \"pnfOamIpv4Address\": \"val3\",\n" +
            "    \"pnfFamily\": \"val5\",\n" +
            "    \"pnfModelNumber\": \"val6\",\n" +
            "    \"pnfSoftwareVersion\": \"val7\",\n" +
            "    \"pnfType\": \"val8\",\n" +
            "    \"eventName\": \"val9\",\n" +
            "    \"nfNamingCode\": \"val10\",\n" +
            "    \"nfcNamingCode\": \"val11\",\n" +
            "    \"sourceName\": \"val12\",\n" +
            "    \"sourceId\": \"val13\",\n" +
            "    \"reportingEntityName\": \"val14\"\n" +
            "}");

    private TestMessages() {
    }
}
