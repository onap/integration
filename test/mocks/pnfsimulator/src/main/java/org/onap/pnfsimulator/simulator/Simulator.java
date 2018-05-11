package org.onap.pnfsimulator.simulator;

import java.time.Duration;
import java.time.Instant;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONObject;
import org.onap.pnfsimulator.simulator.client.HttpClientProvider;

public class Simulator {

    private static final Logger logger = LogManager.getLogger(HttpClientProvider.class);
    private HttpClientProvider clientProvider;
    private JSONObject messageBody;
    private Duration duration;
    private Duration interval;

    public Simulator(String vesServerUrl, JSONObject messageBody, Duration duration, Duration interval) {
        this.messageBody = messageBody;
        this.duration = duration;
        this.interval = interval;
        this.clientProvider = new HttpClientProvider(vesServerUrl);
    }

    public void start() {
        logger.info("SIMULATOR STARTED - DURATION: {}s, INTERVAL: {}s", duration.getSeconds(), interval.getSeconds());

        Instant endTime = Instant.now().plus(duration);
        while (runningTimeNotExceeded(endTime)) {
            try {
                logger.info("MESSAGE TO BE SENT:\n{}", messageBody.toString(4));
                clientProvider.sendMsg(messageBody.toString());
                Thread.sleep(interval.toMillis());
            } catch (InterruptedException e) {
                logger.error("SIMULATOR INTERRUPTED");
                break;
            }
        }
        logger.info("SIMULATOR FINISHED");
    }

    private boolean runningTimeNotExceeded(Instant endTime) {
        return Instant.now().isBefore(endTime);
    }
}