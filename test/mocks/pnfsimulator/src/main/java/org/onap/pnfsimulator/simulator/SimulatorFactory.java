package org.onap.pnfsimulator.simulator;

import static org.onap.pnfsimulator.message.MessageConstants.MESSAGE_INTERVAL;
import static org.onap.pnfsimulator.message.MessageConstants.TEST_DURATION;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.List;
import org.apache.commons.io.FileUtils;
import org.json.JSONObject;
import org.onap.pnfsimulator.message.MessageProvider;
import org.onap.pnfsimulator.simulator.validation.ParamsValidator;
import org.onap.pnfsimulator.simulator.validation.ValidationException;

public class SimulatorFactory {

    private MessageProvider messageProvider;
    private ParamsValidator paramsValidator;

    public SimulatorFactory(MessageProvider messageProvider, ParamsValidator paramsValidator) {
        this.messageProvider = messageProvider;
        this.paramsValidator = paramsValidator;
    }

    public Simulator create(String vesServerUrl, String configFilePath) throws IOException, ValidationException {

        String configJson = FileUtils.readFileToString(new File(configFilePath), StandardCharsets.UTF_8);
        JSONObject configObject = new JSONObject(configJson);

        paramsValidator.validate(configObject);
        Duration duration = Duration.ofSeconds(parseJsonField(configObject, TEST_DURATION));
        Duration interval = Duration.ofSeconds(parseJsonField(configObject, MESSAGE_INTERVAL));
        JSONObject messageBody = messageProvider.createMessage(configObject);
        return new Simulator(vesServerUrl, messageBody, duration, interval);
    }

    private int parseJsonField(JSONObject json, String fieldName) {
        return Integer.parseInt((String) json.remove(fieldName));
    }
}