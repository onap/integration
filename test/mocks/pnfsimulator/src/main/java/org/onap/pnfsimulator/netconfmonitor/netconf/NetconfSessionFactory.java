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

package org.onap.pnfsimulator.netconfmonitor.netconf;

import com.tailf.jnc.JNCException;
import com.tailf.jnc.NetconfSession;
import com.tailf.jnc.SSHConnection;
import com.tailf.jnc.SSHSession;

import java.io.IOException;

public final class NetconfSessionFactory {
    private NetconfSessionFactory() {}

    public static NetconfSession create(NetconfConnectionParams params) throws IOException, JNCException {
        SSHConnection sshConnection = new SSHConnection(params.address, params.port);
        sshConnection.authenticateWithPassword(params.user, params.password);
        SSHSession sshSession = new SSHSession(sshConnection);
        return new NetconfSession(sshSession);
    }
}
