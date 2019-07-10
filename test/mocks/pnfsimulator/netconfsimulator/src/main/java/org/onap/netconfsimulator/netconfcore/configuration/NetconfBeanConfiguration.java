/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2018 Nokia. All rights reserved.
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

package org.onap.netconfsimulator.netconfcore.configuration;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
class NetconfBeanConfiguration {

    private static final Logger LOGGER = LoggerFactory.getLogger(NetconfBeanConfiguration.class);

    @Value("${netconf.port}")
    private Integer netconfPort;

    @Value("${netconf.address}")
    private String netconfAddress;

    @Value("${netconf.user}")
    private String netconfUser;

    @Value("${netconf.password}")
    private String netconfPassword;

    @Bean
    NetconfConfigurationReader configurationReader() {
        NetconfConnectionParams params = new NetconfConnectionParams(netconfAddress, netconfPort, netconfUser, netconfPassword);
        LOGGER.info("Configuration params are : {}", params);
        return new NetconfConfigurationReader(params, new NetconfSessionHelper());
    }

    @Bean
    NetconfConfigurationEditor configurationEditor() {
        NetconfConnectionParams params =
                new NetconfConnectionParams(netconfAddress, netconfPort, netconfUser, netconfPassword);
        return new NetconfConfigurationEditor(params, new NetconfSessionHelper());
    }

}
