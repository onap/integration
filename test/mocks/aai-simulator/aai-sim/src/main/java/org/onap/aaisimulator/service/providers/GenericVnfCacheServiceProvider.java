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

import java.util.List;
import java.util.Optional;
import org.onap.aai.domain.yang.GenericVnf;
import org.onap.aai.domain.yang.Relationship;
import org.springframework.http.HttpHeaders;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public interface GenericVnfCacheServiceProvider extends Clearable {

    void putGenericVnf(final String vnfId, final GenericVnf genericVnf);

    Optional<GenericVnf> getGenericVnf(final String vnfId);

    Optional<Relationship> addRelationShip(final String vnfId, final Relationship relationship,
            final String requestURI);

    boolean addRelationShip(final HttpHeaders incomingHeader, final String targetBaseUrl, final String requestUriString,
            final String vnfId, final Relationship relationship);

    Optional<String> getGenericVnfId(final String vnfName);

    boolean patchGenericVnf(final String vnfId, final GenericVnf genericVnf);

    List<GenericVnf> getGenericVnfs(final String selflink);

    boolean deleteGenericVnf(final String vnfId, final String resourceVersion);


}
