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

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Optional;
import org.json.JSONObject;

public final class TestMessages {

    static final JSONObject VALID_SIMULATOR_PARAMS = new JSONObject(getContent("validSimulatorParams.json"));
    public static final JSONObject VALID_COMMON_EVENT_HEADER_PARAMS = new JSONObject(getContent("validCommonEventHeaderParams.json"));
    static final Optional<JSONObject> VALID_PNF_REGISTRATION_PARAMS = Optional
        .of(new JSONObject(getContent("validPnfRegistrationParams.json")));
    public static final Optional<JSONObject> VALID_NOTIFICATION_PARAMS = Optional
        .of(new JSONObject(getContent("validNotificationParams.json")));

    static final JSONObject INVALID_SIMULATOR_PARAMS = new JSONObject(
        "{\n" +
            "    \"vesServerUrl\": \"http://10.42.111.42:8080/eventListener/v5\",\n" +
            "    \"messageInterval\": \"1\"\n" +
            "}");


    static final Optional<JSONObject> INVALID_PNF_REGISTRATION_PARAMS_1 = Optional.of(new JSONObject(
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
            "}"));

    static final Optional<JSONObject> INVALID_PNF_REGISTRATION_PARAMS_2 = Optional.of(new JSONObject(
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
            "}"));

    static final Optional<JSONObject> INVALID_PNF_REGISTRATION_PARAMS_3 = Optional.of(new JSONObject(
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
            "}"));

    static final Optional<JSONObject> INVALID_NOTIFICATION_PARAMS = Optional.of(new JSONObject(
        "{\n" +
            "    \"mother\": \"val1\",\n" +
            "    \"father\": \"val3\",\n" +
            "}"));


    private TestMessages() {
    }

    private static String getContent(String fileName) {
        try {
            String pathAsString = TestMessages.class.getResource(fileName).getPath();
            StringBuilder stringBuilder = new StringBuilder();
            Files.readAllLines(Paths.get(pathAsString)).forEach(line -> {
                stringBuilder.append(line);
            });
            return stringBuilder.toString();
        } catch (IOException e) {
            throw new RuntimeException(String.format("Cannot read JSON file %s", fileName));
        }
    }
}
