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
import com.tailf.jnc.NetconfSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.onap.pnfsimulator.netconfmonitor.netconf.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.IOException;
import java.util.Map;
import java.util.Timer;

@Configuration
public class NetconfMonitorServiceConfiguration {
    private static final Logger LOGGER = LogManager.getLogger(NetconfMonitorServiceConfiguration.class);
    private static final Map<String, String> enviroment = System.getenv();

    private static final String LOG_PATH = "/var/log";

    private static final String NETCONF_ADDRESS = "NETCONF_ADDRESS";
    private static final String NETCONF_PORT = "NETCONF_PORT";
    private static final String NETCONF_MODEL = "NETCONF_MODEL";
    private static final String NETCONF_MAIN_CONTAINER = "NETCONF_MAIN_CONTAINER";

    private static final String DEFAULT_NETCONF_ADDRESS = "netopeer";
    private static final int DEFAULT_NETCONF_PORT = 830;
    private static final String DEFAULT_NETCONF_MODEL = "pnf-simulator";
    private static final String DEFAULT_NETCONF_MAIN_CONTAINER = "config";

    private static final String DEFAULT_NETCONF_USER = "netconf";
    private static final String DEFAULT_NETCONF_PASSWORD = "netconf";

    @Bean
    public Timer timer() {
        return new Timer("NetconfMonitorServiceTimer");
    }

    @Bean
    public NetconfConfigurationCache configurationCache() {
        return new NetconfConfigurationCache();
    }

    @Bean
    public NetconfConfigurationReader configurationReader() throws IOException, JNCException {
        NetconfConnectionParams params = createConnectionParams();
        LOGGER.info("Configuration params are : {}", params);
        NetconfSession session = NetconfSessionFactory.create(params);
        return new NetconfConfigurationReader(session, buildModelPath());
    }

    @Bean
    public NetconfConfigurationWriter netconfConfigurationWriter() {
        return new NetconfConfigurationWriter(LOG_PATH);
    }

    private String buildModelPath() {
        return String.format("/%s:%s",
                enviroment.getOrDefault(NETCONF_MODEL, DEFAULT_NETCONF_MODEL),
                enviroment.getOrDefault(NETCONF_MAIN_CONTAINER, DEFAULT_NETCONF_MAIN_CONTAINER));
    }

    private NetconfConnectionParams createConnectionParams() {
        return new NetconfConnectionParams(
                enviroment.getOrDefault(NETCONF_ADDRESS, DEFAULT_NETCONF_ADDRESS),
                resolveNetconfPort(),
                DEFAULT_NETCONF_USER,
                DEFAULT_NETCONF_PASSWORD);
    }

    private int resolveNetconfPort() {
        try {
            return Integer.parseInt(enviroment.get(NETCONF_PORT));
        } catch (NumberFormatException e) {
            return DEFAULT_NETCONF_PORT;
        }
    }
}
