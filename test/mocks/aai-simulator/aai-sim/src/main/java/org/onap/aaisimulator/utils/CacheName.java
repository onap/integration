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
package org.onap.aaisimulator.utils;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public enum CacheName {

    CUSTOMER_CACHE("customer-cache"),
    PROJECT_CACHE("project-cache"),
    NODES_CACHE("nodes-cache"),
    GENERIC_VNF_CACHE("generic-vnf-cache"),
    PNF_CACHE("pnf-cache"),
    OWNING_ENTITY_CACHE("owning-entity-cache"),
    PLATFORM_CACHE("platform-cache"),
    LINES_OF_BUSINESS_CACHE("lines-of-business-cache"),
    CLOUD_REGION_CACHE("cloud-region-cache"),
    ESR_VNFM_CACHE("esr-vnfm-cache");

    private String name;

    private CacheName(final String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }
}
