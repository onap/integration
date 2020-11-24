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

package org.onap.pnfsimulator.netconfmonitor.netconf;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import org.onap.pnfsimulator.rest.util.DateUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class NetconfConfigurationWriter {

    private static final Logger LOGGER = LoggerFactory.getLogger(NetconfConfigurationWriter.class);
    private static final DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd_HH:mm:ss");
    private String pathToLog;

    public NetconfConfigurationWriter(String pathToLog) {
        this.pathToLog = pathToLog;
    }

    public void writeToFile(String configuration) {
        String fileName = String.format("%s/config[%s].xml", pathToLog, DateUtil.getTimestamp(dateFormat));
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(fileName))) {
            writer.write(configuration);
            LOGGER.info("Configuration wrote to file {}/{} ", pathToLog, fileName);
        } catch (IOException e) {
            LOGGER.warn("Failed to write configuration to file: {}", e.getMessage());
        }
    }
}
