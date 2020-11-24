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

public class NetconfConnectionParams {

    public final String address;
    public final int port;
    public final String user;
    public final String password;

    public NetconfConnectionParams(String address, int port, String user, String password) {
        this.address = address;
        this.port = port;
        this.user = user;
        this.password = password;
    }

    @Override
    public String toString() {
        return String.format("NetconfConnectionParams{address=%s, port=%d, user=%s, password=%s}",
            address,
            port,
            user,
            password);
    }
}