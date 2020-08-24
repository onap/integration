/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2019 Nordix Foundation.
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
 *
 * SPDX-License-Identifier: Apache-2.0
 * ============LICENSE_END=========================================================
 */
package org.onap.aaisimulator.service.providers;

import java.util.Optional;
import org.onap.aai.domain.yang.GenericVnfs;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aaisimulator.models.NodeServiceInstance;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public interface NodesCacheServiceProvider extends Clearable {

    void putNodeServiceInstance(final String serviceInstanceId, final NodeServiceInstance nodeServiceInstance);

    Optional<NodeServiceInstance> getNodeServiceInstance(final String serviceInstanceId);

    Optional<GenericVnfs> getGenericVnfs(final String vnfName);

    Optional<ServiceInstance> getServiceInstance(final NodeServiceInstance nodeServiceInstance);

}
