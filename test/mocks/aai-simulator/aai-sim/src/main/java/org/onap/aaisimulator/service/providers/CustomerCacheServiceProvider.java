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
import org.onap.aai.domain.yang.Customer;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aai.domain.yang.ServiceInstances;
import org.onap.aai.domain.yang.ServiceSubscription;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public interface CustomerCacheServiceProvider extends Clearable {

    Optional<Customer> getCustomer(final String globalCustomerId);

    void putCustomer(final String globalCustomerId, final Customer customer);

    Optional<ServiceSubscription> getServiceSubscription(final String globalCustomerId, final String serviceType);

    boolean putServiceSubscription(final String globalCustomerId, final String serviceType,
            final ServiceSubscription serviceSubscription);

    Optional<ServiceInstances> getServiceInstances(final String globalCustomerId, final String serviceType,
            final String serviceInstanceName);

    Optional<ServiceInstance> getServiceInstance(final String globalCustomerId, final String serviceType,
            final String serviceInstanceId);

    boolean putServiceInstance(final String globalCustomerId, final String serviceType, final String serviceInstanceId,
            final ServiceInstance serviceInstance);

    boolean patchServiceInstance(final String globalCustomerId, final String serviceType,
            final String serviceInstanceId, final ServiceInstance serviceInstance);

    Optional<Relationship> getRelationship(final String globalCustomerId, final String serviceType,
            final String serviceInstanceId, final String vnfName);

    Optional<Relationship> addRelationShip(final String globalCustomerId, final String serviceType,
            final String serviceInstanceId, final Relationship relationship, final String requestUri);

    boolean deleteSericeInstance(final String globalCustomerId, final String serviceType,
            final String serviceInstanceId, final String resourceVersion);

}
