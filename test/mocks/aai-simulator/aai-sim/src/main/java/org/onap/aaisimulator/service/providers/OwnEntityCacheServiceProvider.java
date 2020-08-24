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
import org.onap.aai.domain.yang.OwningEntity;
import org.onap.aai.domain.yang.Relationship;
import org.springframework.http.HttpHeaders;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public interface OwnEntityCacheServiceProvider extends Clearable {

    void putOwningEntity(final String owningEntityId, final OwningEntity owningEntity);

    Optional<OwningEntity> getOwningEntity(final String owningEntityId);

    boolean addRelationShip(final HttpHeaders incomingHeader, final String targetBaseUrl, final String requestUriString,
            final String owningEntityId, final Relationship relationship);

}
