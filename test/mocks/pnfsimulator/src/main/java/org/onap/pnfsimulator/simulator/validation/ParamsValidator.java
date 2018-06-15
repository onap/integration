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

package org.onap.pnfsimulator.simulator.validation;

import static org.onap.pnfsimulator.message.MessageConstants.MESSAGE_INTERVAL;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_OAM_IPV4_ADDRESS;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_OAM_IPV6_ADDRESS;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_SERIAL_NUMBER;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_VENDOR_NAME;
import static org.onap.pnfsimulator.message.MessageConstants.TEST_DURATION;
import static org.onap.pnfsimulator.message.MessageConstants.VES_SERVER_URL;

import com.google.common.collect.ImmutableMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.function.BiPredicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;


public class ParamsValidator {

    private final static String MISSING_PARAMS_MESSAGE = "Following mandatory params are missing:\n";

    private final Map<String, BiPredicate<String, JSONObject>> simulatorParamsValidators = ImmutableMap
        .<String, BiPredicate<String, JSONObject>>builder()
        .put(VES_SERVER_URL, this::isDefined)
        .put(TEST_DURATION, this::isNumeric)
        .put(MESSAGE_INTERVAL, this::isNumeric)
        .build();

    private final Map<String, BiPredicate<String, JSONObject>> messageParamsValidators = ImmutableMap
        .<String, BiPredicate<String, JSONObject>>builder()
        .put(PNF_SERIAL_NUMBER, this::isDefined)
        .put(PNF_VENDOR_NAME, this::isDefined)
        .put(PNF_OAM_IPV4_ADDRESS, this::isDefined)
        .put(PNF_OAM_IPV6_ADDRESS, this::isDefined)
        .build();

    private JSONObject simulatorParams;
    private JSONObject messageParams;

    private ParamsValidator(JSONObject simulatorParams, JSONObject messageParams) {
        this.simulatorParams = simulatorParams;
        this.messageParams = messageParams;
    }

    public static ParamsValidator forParams(JSONObject simulatorParams, JSONObject messageParams) {
        return new ParamsValidator(simulatorParams, messageParams);
    }

    public void validate() throws ValidationException {

        Stream<String> missingSimulatorParams = simulatorParamsValidators
            .entrySet()
            .stream()
            .filter(entry -> !entry.getValue().test(entry.getKey(), simulatorParams))
            .map(Entry::getKey);

        Stream<String> missingMessageParams = messageParamsValidators
            .entrySet()
            .stream()
            .filter(entry -> !entry.getValue().test(entry.getKey(), messageParams))
            .map(Entry::getKey);

        List<String> missingParams = Stream
            .concat(missingMessageParams, missingSimulatorParams)
            .collect(Collectors.toList());

        resolveMissingIP(missingParams);

        if (!missingParams.isEmpty()) {
            throw new ValidationException(constructMessage(missingParams));
        }
    }

    private String constructMessage(List<String> missingParams) {

        return MISSING_PARAMS_MESSAGE + missingParams
            .stream()
            .collect(Collectors.joining("\n"));
    }

    private boolean isNumeric(String param, JSONObject container) {
        return isDefined(param, container) && StringUtils.isNumeric(container.getString(param));
    }

    private boolean isDefined(String param, JSONObject container) {

        return container.has(param) && !container.getString(param).isEmpty();
    }

    private void resolveMissingIP(List<String> missingParams) {
        // if only one IP is missing clear the error
        if (!(missingParams.contains(PNF_OAM_IPV4_ADDRESS) && missingParams.contains(PNF_OAM_IPV6_ADDRESS))) {
            missingParams.remove(PNF_OAM_IPV4_ADDRESS);
            missingParams.remove(PNF_OAM_IPV6_ADDRESS);
        }
    }
}
