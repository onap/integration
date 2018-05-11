package org.onap.pnfsimulator.simulator.validation;

import static org.onap.pnfsimulator.message.MessageConstants.MESSAGE_INTERVAL;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_OAM_IPV4_ADDRESS;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_OAM_IPV6_ADDRESS;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_SERIAL_NUMBER;
import static org.onap.pnfsimulator.message.MessageConstants.PNF_VENDOR_NAME;
import static org.onap.pnfsimulator.message.MessageConstants.TEST_DURATION;

import com.google.common.collect.ImmutableMap;
import java.util.ArrayList;
import java.util.List;
import java.util.function.BiPredicate;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;


public class ParamsValidator {

    private final static String MISSING_PARAMS_ERROR = "Some mandatory params are missing";
    private static ParamsValidator instance;


    public static ParamsValidator getInstance() {
        if (instance == null) {
            instance = new ParamsValidator();
        }
        return instance;
    }

    public void validate(JSONObject params) throws ValidationException {
        ImmutableMap<String, BiPredicate<JSONObject, String>> paramValidators = ImmutableMap
            .<String, BiPredicate<JSONObject, String>>builder()
            .put(TEST_DURATION, this::isNotNumeric)
            .put(MESSAGE_INTERVAL, this::isNotNumeric)
            .put(PNF_SERIAL_NUMBER, this::nullOrEmpty)
            .put(PNF_VENDOR_NAME, this::nullOrEmpty)
            .put(PNF_OAM_IPV4_ADDRESS, this::nullOrEmpty)
            .put(PNF_OAM_IPV6_ADDRESS, this::nullOrEmpty)
            .build();

        List<String> missingParams = new ArrayList<>();

        paramValidators.forEach((param, validator) -> {
            if (validator.test(params, param)) {
                missingParams.add(param);
            }
        });

        clearIPError(missingParams);
        if (!missingParams.isEmpty()) {
            throw new ValidationException(constructMessage(missingParams));
        }
    }

    private String constructMessage(List<String> missingParams) {
        StringBuilder msg = new StringBuilder(MISSING_PARAMS_ERROR);

        missingParams.forEach(param -> {
            msg.append('\n');
            msg.append(param);
        });

        return msg.toString();
    }

    private boolean isNotNumeric(JSONObject params, String param) {
        return nullOrEmpty(params, param) || !StringUtils.isNumeric(params.getString(param));
    }

    private boolean nullOrEmpty(JSONObject params, String param) {
        return !params.has(param) || params.getString(param).isEmpty();
    }

    private void clearIPError(List<String> missingParams) {
        // if only one IP is missing clear the error
        if (!(missingParams.contains(PNF_OAM_IPV4_ADDRESS) && missingParams.contains(PNF_OAM_IPV6_ADDRESS))) {
            missingParams.remove(PNF_OAM_IPV4_ADDRESS);
            missingParams.remove(PNF_OAM_IPV6_ADDRESS);
        }
    }
}
