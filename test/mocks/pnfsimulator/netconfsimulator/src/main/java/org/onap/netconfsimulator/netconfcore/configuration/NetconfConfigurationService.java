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

import com.tailf.jnc.Element;
import com.tailf.jnc.JNCException;
import com.tailf.jnc.XMLParser;

import java.io.ByteArrayInputStream;
import java.io.IOException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.xml.sax.InputSource;

@Service
public class NetconfConfigurationService {

    private static final Logger LOGGER = LoggerFactory.getLogger(NetconfConfigurationService.class);
    private static final String CONFIGURATION_HAS_BEEN_ACTIVATED = "New configuration has been activated";

    private final NetconfConfigurationReader netconfConfigurationReader;
    private NetconfConfigurationEditor configurationEditor;
    private XMLParser parser;

    @Autowired
    public NetconfConfigurationService(NetconfConfigurationReader netconfConfigurationReader,
                                       NetconfConfigurationEditor netconfConfigurationEditor) throws JNCException {
        this.netconfConfigurationReader = netconfConfigurationReader;
        this.configurationEditor = netconfConfigurationEditor;
        this.parser = new XMLParser();
    }

    public String getCurrentConfiguration() throws IOException, JNCException {
        return netconfConfigurationReader.getRunningConfig();
    }

    public String getCurrentConfiguration(String model, String container) throws IOException, JNCException {
        String path = String.format("/%s:%s", model, container);
        return netconfConfigurationReader.getRunningConfig(path);
    }

    public String editCurrentConfiguration(MultipartFile newConfiguration) throws IOException, JNCException {
        Element configurationElement = convertMultipartToXmlElement(newConfiguration);
        configurationEditor.editConfig(configurationElement);

        LOGGER.debug("Loading new configuration: \n{}", configurationElement.toXMLString());
        return CONFIGURATION_HAS_BEEN_ACTIVATED;
    }

    private Element convertMultipartToXmlElement(MultipartFile editConfig) throws IOException, JNCException {
        InputSource inputSourceUpdateConfig = new InputSource(new ByteArrayInputStream(editConfig.getBytes()));
        return parser.parse(inputSourceUpdateConfig);
    }
}
