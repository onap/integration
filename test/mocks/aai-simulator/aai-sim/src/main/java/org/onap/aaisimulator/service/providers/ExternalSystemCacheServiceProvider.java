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
import org.onap.aai.domain.yang.EsrSystemInfo;
import org.onap.aai.domain.yang.EsrSystemInfoList;
import org.onap.aai.domain.yang.EsrVnfm;
import org.onap.aai.domain.yang.Relationship;
import org.springframework.http.HttpHeaders;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public interface ExternalSystemCacheServiceProvider extends Clearable {

    void putEsrVnfm(final String vnfmId, final EsrVnfm esrVnfm);

    Optional<EsrVnfm> getEsrVnfm(final String vnfmId);

    List<EsrVnfm> getAllEsrVnfm();

    Optional<EsrSystemInfoList> getEsrSystemInfoList(final String vnfmId);

    boolean putEsrSystemInfo(final String vnfmId, final String esrSystemInfoId, final EsrSystemInfo esrSystemInfo);

    boolean addRelationShip(final HttpHeaders incomingHeader, final String targetBaseUrl, final String requestURI,
            final String vnfmId, Relationship relationship);
}
