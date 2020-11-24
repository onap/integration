/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================ Copyright (C)
 * 2018 NOKIA Intellectual Property. All rights reserved.
 * ================================================================================ Licensed under
 * the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License. ============LICENSE_END=========================================================
 */

package org.onap.pnfsimulator.netconfmonitor.netconf;

import com.tailf.jnc.JNCException;
import com.tailf.jnc.NetconfSession;
import java.io.IOException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class NetconfConfigurationReader {

    private static final Logger LOGGER = LoggerFactory.getLogger(NetconfConfigurationReader.class);
    private final NetconfSession session;
    private final String netconfModelPath;

    public NetconfConfigurationReader(NetconfSession session, String netconfModelPath) {
        LOGGER.warn("netconfModelPath: {}", netconfModelPath);
        this.session = session;
        this.netconfModelPath = netconfModelPath;
    }

    public String read() throws IOException, JNCException {
        return session.getConfig(netconfModelPath).first().toXMLString();
    }
}
