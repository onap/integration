/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2020 Nordix Foundation.
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

import org.onap.aai.domain.yang.v15.Pnf;

import java.util.List;
import java.util.Optional;

/**
 * @author Raj Gumma (raj.gumma@est.tech)
 */
public interface PnfCacheServiceProvider extends Clearable {

    void putPnf(final String pnfId, final Pnf pnf);

    Optional<Pnf> getPnf(final String pnfId);

    Optional<String> getPnfId(final String pnfName);

    boolean patchPnf(final String pnfId, final Pnf pnf);

    List<Pnf> getPnfs(final String selflink);

    boolean deletePnf(final String pnfId, final String resourceVersion);


}
