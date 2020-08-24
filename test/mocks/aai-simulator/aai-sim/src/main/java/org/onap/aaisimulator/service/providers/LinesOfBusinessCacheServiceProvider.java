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
import org.onap.aai.domain.yang.LineOfBusiness;
import org.onap.aai.domain.yang.Relationship;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public interface LinesOfBusinessCacheServiceProvider extends Clearable {

    void putLineOfBusiness(final String lineOfBusinessName, final LineOfBusiness lineOfBusiness);

    Optional<LineOfBusiness> getLineOfBusiness(final String lineOfBusinessName);

    Optional<Relationship> addRelationShip(final String lineOfBusinessName, final Relationship relationship,
            final String requestURI);


}
