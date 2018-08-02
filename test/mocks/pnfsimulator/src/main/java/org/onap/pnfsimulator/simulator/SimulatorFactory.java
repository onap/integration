package org.onap.pnfsimulator.simulator;

import static java.lang.Integer.parseInt;
import static org.onap.pnfsimulator.message.MessageConstants.MESSAGE_INTERVAL;
import static org.onap.pnfsimulator.message.MessageConstants.TEST_DURATION;
import static org.onap.pnfsimulator.message.MessageConstants.VES_SERVER_URL;

import com.github.fge.jsonschema.core.exceptions.ProcessingException;
import java.io.IOException;
import java.time.Duration;
import org.json.JSONObject;
import org.onap.pnfsimulator.message.MessageProvider;
import org.onap.pnfsimulator.simulator.validation.JSONValidator;
import org.onap.pnfsimulator.simulator.validation.ValidationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class SimulatorFactory {

    private static final String DEFAULT_OUTPUT_SCHEMA_PATH = "json_schema/output_validator.json";

    private MessageProvider messageProvider;
    private JSONValidator validator;

    @Autowired
    public SimulatorFactory(MessageProvider messageProvider, JSONValidator validator) {
        this.messageProvider = messageProvider;
        this.validator = validator;
    }

    public Simulator create(JSONObject simulatorParams, JSONObject messageParams)
        throws ProcessingException, IOException, ValidationException {
        Duration duration = Duration.ofSeconds(parseInt(simulatorParams.getString(TEST_DURATION)));
        Duration interval = Duration.ofSeconds(parseInt(simulatorParams.getString(MESSAGE_INTERVAL)));
        String vesUrl = simulatorParams.getString(VES_SERVER_URL);

        JSONObject messageBody = messageProvider.createMessage(messageParams);
        validator.validate(messageBody.toString(), DEFAULT_OUTPUT_SCHEMA_PATH);

        return Simulator.builder()
            .withVesUrl(vesUrl)
            .withDuration(duration)
            .withInterval(interval)
            .withMessageBody(messageBody)
            .build();
    }
}