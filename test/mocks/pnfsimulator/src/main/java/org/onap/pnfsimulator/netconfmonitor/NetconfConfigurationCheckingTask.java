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

package org.onap.pnfsimulator.netconfmonitor;

import com.tailf.jnc.JNCException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationCache;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationReader;
import org.onap.pnfsimulator.netconfmonitor.netconf.NetconfConfigurationWriter;

import java.io.IOException;
import java.util.TimerTask;

public class NetconfConfigurationCheckingTask extends TimerTask {
    private static final Logger LOGGER = LogManager.getLogger(NetconfConfigurationCheckingTask.class);

    private final NetconfConfigurationReader reader;
    private final NetconfConfigurationWriter writer;
    private final NetconfConfigurationCache cache;

    public NetconfConfigurationCheckingTask(NetconfConfigurationReader reader,
        NetconfConfigurationWriter writer,
        NetconfConfigurationCache cache) {
        this.reader = reader;
        this.writer = writer;
        this.cache = cache;
    }

    @Override
    public void run() {
        String currentConfiguration = "";
        try {
            currentConfiguration = reader.read();
        } catch (IOException|JNCException e) {
            LOGGER.info("Error during configuration reading: {}", e.getMessage());
        }
        if (!currentConfiguration.equals(cache.getConfiguration())) {
            LOGGER.info("Configuration has changed, new configuration:\n\n{}", currentConfiguration);
            writer.writeToFile(currentConfiguration);
            cache.update(currentConfiguration);
        }
    }
}
