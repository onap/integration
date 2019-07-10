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
 *            http://www.apache.org/licenses/LICENSE-2.0
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
import com.tailf.jnc.NetconfSession;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;

@Slf4j
public class NetconfConfigurationEditor {

    private NetconfConnectionParams params;
    private NetconfSessionHelper netconfSessionHelper;

    public NetconfConfigurationEditor(NetconfConnectionParams params, NetconfSessionHelper netconfSessionHelper) {
        this.params = params;
        this.netconfSessionHelper = netconfSessionHelper;
    }

    void editConfig(Element configurationXmlElement) throws JNCException, IOException {
        log.debug("New configuration passed to simulator: {}", configurationXmlElement.toXMLString());
        NetconfSession session = netconfSessionHelper.createNetconfSession(params);
        session.editConfig(configurationXmlElement);
        session.closeSession();

        log.info("Successfully updated configuration");
    }

}
