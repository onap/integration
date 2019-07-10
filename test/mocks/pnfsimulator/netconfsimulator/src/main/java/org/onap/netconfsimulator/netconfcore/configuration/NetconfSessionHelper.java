/*-
 * ============LICENSE_START=======================================================
 * Simulator
 * ================================================================================
 * Copyright (C) 2019 Nokia. All rights reserved.
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
import com.tailf.jnc.SSHConnection;
import com.tailf.jnc.SSHSession;
import java.io.IOException;

class NetconfSessionHelper {

    NetconfSession createNetconfSession(NetconfConnectionParams params) throws IOException, JNCException {
        SSHConnection sshConnection = new SSHConnection(params.getAddress(), params.getPort());
        sshConnection.authenticateWithPassword(params.getUser(), params.getPassword());
        return new NetconfSession(new SSHSession(sshConnection));
    }

}
