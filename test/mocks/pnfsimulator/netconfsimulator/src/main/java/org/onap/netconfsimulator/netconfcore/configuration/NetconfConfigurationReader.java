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

import com.tailf.jnc.JNCException;
import com.tailf.jnc.NetconfSession;
import com.tailf.jnc.NodeSet;
import java.io.IOException;
import java.util.Objects;

class NetconfConfigurationReader {

    private NetconfConnectionParams params;
    private NetconfSessionHelper netconfSessionHelper;

    NetconfConfigurationReader(NetconfConnectionParams params, NetconfSessionHelper netconfSessionHelper) {
        this.params = params;
        this.netconfSessionHelper = netconfSessionHelper;
    }

    String getRunningConfig() throws IOException, JNCException {
        NetconfSession session = netconfSessionHelper.createNetconfSession(params);
        String config = session.getConfig().toXMLString();
        session.closeSession();
        return config;
    }

    String getRunningConfig(String modelPath) throws IOException, JNCException {
        NetconfSession session = netconfSessionHelper.createNetconfSession(params);
        NodeSet config = session.getConfig(modelPath);
        if (Objects.isNull(config) || Objects.isNull(config.first())) {
            throw new JNCException(JNCException.ELEMENT_MISSING, modelPath);
        }
        session.closeSession();
        return config.first().toXMLString();
    }


}
