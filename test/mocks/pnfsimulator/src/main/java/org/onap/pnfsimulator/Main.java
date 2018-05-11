package org.onap.pnfsimulator;

import java.io.IOException;
import org.apache.commons.cli.ParseException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.onap.pnfsimulator.cli.SimulatorParamsProvider;
import org.onap.pnfsimulator.cli.SimulatorParams;
import org.onap.pnfsimulator.message.MessageProvider;
import org.onap.pnfsimulator.simulator.SimulatorFactory;
import org.onap.pnfsimulator.simulator.validation.ParamsValidator;
import org.onap.pnfsimulator.simulator.validation.ValidationException;

public class Main {

    private static Logger logger = LogManager.getLogger(Main.class);
    private static SimulatorFactory simulatorFactory =
        new SimulatorFactory(MessageProvider.getInstance(), ParamsValidator.getInstance());

    public static void main(String[] args) {

        try {

            SimulatorParams params = new SimulatorParamsProvider().parse(args);
            simulatorFactory
                .create(params.getVesAddress(), params.getConfigFilePath())
                .start();

        } catch (IOException e) {
            logger.error("Invalid config file format", e);
        } catch (ParseException e) {
            logger.error("Invalid cli params", e);
        } catch (ValidationException e){
            logger.error("Missing some mandatory params:", e);
        }
    }
}
