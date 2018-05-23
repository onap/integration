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

package org.onap.pnfsimulator.cli;

import java.util.Objects;

public class SimulatorParams {

    private String vesAddress;
    private String configFilePath;

    public SimulatorParams(String vesAddress, String configFilePath) {
        this.vesAddress = vesAddress;
        this.configFilePath = configFilePath;
    }

    public String getVesAddress() {
        return vesAddress;
    }

    public String getConfigFilePath() {
        return configFilePath;
    }

    @Override
    public String toString() {
        return String.format("VES address=%s, Configuration file=%s", vesAddress, configFilePath);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof SimulatorParams)) {
            return false;
        }
        SimulatorParams params = (SimulatorParams) o;
        return Objects.equals(vesAddress, params.vesAddress) &&
            Objects.equals(configFilePath, params.configFilePath);
    }

    @Override
    public int hashCode() {
        return Objects.hash(vesAddress, configFilePath);
    }
}
