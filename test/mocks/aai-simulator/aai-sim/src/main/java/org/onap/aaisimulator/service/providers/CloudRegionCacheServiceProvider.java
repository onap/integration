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
import org.onap.aai.domain.yang.CloudRegion;
import org.onap.aai.domain.yang.EsrSystemInfo;
import org.onap.aai.domain.yang.EsrSystemInfoList;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.Tenant;
import org.onap.aai.domain.yang.Vserver;
import org.onap.aaisimulator.models.CloudRegionKey;
import org.springframework.http.HttpHeaders;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public interface CloudRegionCacheServiceProvider extends Clearable {

    void putCloudRegion(final CloudRegionKey cloudRegionKey, final CloudRegion cloudRegion);

    Optional<CloudRegion> getCloudRegion(final CloudRegionKey cloudRegionKey);

    Optional<Relationship> addRelationShip(final CloudRegionKey key, final Relationship relationship,
            final String requestUri);

    boolean putTenant(final CloudRegionKey key, final String tenantId, Tenant tenant);

    Optional<Tenant> getTenant(final CloudRegionKey key, final String tenantId);

    boolean addRelationShip(final HttpHeaders incomingHeader, final String targetBaseUrl, final String requestURI,
            final CloudRegionKey key, final String tenantId, final Relationship relationship);

    Optional<EsrSystemInfoList> getEsrSystemInfoList(final CloudRegionKey key);

    boolean putEsrSystemInfo(final CloudRegionKey key, final String esrSystemInfoId, final EsrSystemInfo esrSystemInfo);

    boolean putVserver(final CloudRegionKey key, final String tenantId, final String vServerId, Vserver vServer);

    Optional<Vserver> getVserver(final CloudRegionKey key, final String tenantId, final String vServerId);

    boolean deleteVserver(final CloudRegionKey key, final String tenantId, final String vServerId,
            final String resourceVersion);

    Optional<Relationship> addvServerRelationShip(final CloudRegionKey key, final String tenantId,
            final String vServerId, final Relationship relationship, final String requestUri);

    boolean addVServerRelationShip(final HttpHeaders incomingHeader, final String targetBaseUrl, final String requestURI, final CloudRegionKey key,
            final String tenantId, final String vServerId, final Relationship relationship);

}
