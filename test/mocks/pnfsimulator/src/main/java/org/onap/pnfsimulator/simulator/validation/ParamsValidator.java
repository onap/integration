package org.onap.pnfsimulator.simulator.validation;

import static org.onap.pnfsimulator.message.MessageConstants.MESSAGE_INTERVAL;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_OAM_IPV4_ADDRESS;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_OAM_IPV6_ADDRESS;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_SERIAL_NUMBER;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_VENDOR_NAME;
import static org.onap.pnfsimulator.message.MessageConstants.TEST_DURATION;

import com.google.common.collect.ImmutableMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;


public class ParamsValidator {

    private final static String MISSING_PARAMS_MESSAGE = "Following mandatory params are missing:\n";
    private final Map<String, Predicate<String>> validators = ImmutableMap
        .<String, Predicate<String>>builder()
        .put(TEST_DURATION, this::isNumeric)
        .put(MESSAGE_INTERVAL, this::isNumeric)
        .put(PNF_SERIAL_NUMBER, this::isDefined)
        .put(PNF_VENDOR_NAME, this::isDefined)
        .put(PNF_OAM_IPV4_ADDRESS, this::isDefined)
        .put(PNF_OAM_IPV6_ADDRESS, this::isDefined)
        .build();

    private JSONObject subject;

    private ParamsValidator(JSONObject paramsObject) {
        subject = paramsObject;
    }

    public static ParamsValidator forObject(JSONObject configObject) {
        return new ParamsValidator(configObject);
    }

    public void validate() throws ValidationException {

        List<String> missingParams = validators
            .entrySet()
            .stream()
            .filter(entry -> !entry.getValue().test(entry.getKey()))
            .map(Entry::getKey)
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

    private boolean isNumeric(String param) {
        return isDefined(param) && StringUtils.isNumeric(subject.getString(param));
    }

    private boolean isDefined(String param) {
        return subject.has(param) && !subject.getString(param).isEmpty();
    }

    private void resolveMissingIP(List<String> missingParams) {
        // if only one IP is missing clear the error
        if (!(missingParams.contains(PNF_OAM_IPV4_ADDRESS) && missingParams.contains(PNF_OAM_IPV6_ADDRESS))) {
            missingParams.remove(PNF_OAM_IPV4_ADDRESS);
            missingParams.remove(PNF_OAM_IPV6_ADDRESS);
        }
    }
}
