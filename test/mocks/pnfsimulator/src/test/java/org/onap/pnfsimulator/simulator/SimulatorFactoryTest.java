package org.onap.pnfsimulator.simulator;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.onap.pnfsimulator.simulator.TestMessages.INVALID_MESSAGE_PARAMS_1;
import static org.onap.pnfsimulator.simulator.TestMessages.INVALID_MESSAGE_PARAMS_2;
import static org.onap.pnfsimulator.simulator.TestMessages.INVALID_MESSAGE_PARAMS_3;
import static org.onap.pnfsimulator.simulator.TestMessages.INVALID_SIMULATOR_PARAMS;
import static org.onap.pnfsimulator.simulator.TestMessages.VALID_MESSAGE_PARAMS;
import static org.onap.pnfsimulator.simulator.TestMessages.VALID_SIMULATOR_PARAMS;

import com.github.fge.jsonschema.core.exceptions.ProcessingException;
import java.io.IOException;
import org.json.JSONException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.onap.pnfsimulator.message.MessageProvider;
import org.onap.pnfsimulator.simulator.validation.JSONValidator;
import org.onap.pnfsimulator.simulator.validation.ValidationException;

class SimulatorFactoryTest {


    private SimulatorFactory simulatorFactory;

    @BeforeEach
    void setUp() {
        simulatorFactory = new SimulatorFactory(new MessageProvider(), new JSONValidator());
    }

    @Test
    void should_successfully_create_simulator_given_valid_params_and_valid_output_message()
        throws ValidationException, IOException, ProcessingException {
        assertNotNull(simulatorFactory.create(VALID_SIMULATOR_PARAMS, VALID_MESSAGE_PARAMS));
    }

    @Test
    void should_throw_given_invalid_params() {
        assertThrows(
            JSONException.class,
            () -> simulatorFactory.create(INVALID_SIMULATOR_PARAMS, VALID_MESSAGE_PARAMS));
    }

    @Test
    void should_throw_given_valid_params_and_invalid_output_message() {

        assertThrows(
            ValidationException.class,
            () -> simulatorFactory.create(VALID_SIMULATOR_PARAMS, INVALID_MESSAGE_PARAMS_1));

        assertThrows(
            ValidationException.class,
            () -> simulatorFactory.create(VALID_SIMULATOR_PARAMS, INVALID_MESSAGE_PARAMS_2));

        assertThrows(
            ValidationException.class,
            () -> simulatorFactory.create(VALID_SIMULATOR_PARAMS, INVALID_MESSAGE_PARAMS_3));
    }
}