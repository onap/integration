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
 * @author waqas.ikram@ericsson.com
 *
 */
public class TestConstants {

    public static final String BASE_URL_V17 = "/aai/v17";

    public static final String SERVICE_INSTANCES_URL = "/service-instances";

    public static final String SERVICE_NAME = "ServiceTest";

    public static final String SERVICE_INSTANCE_ID = "ccece8fe-13da-456a-baf6-41b3a4a2bc2b";

    public static final String SERVICE_INSTANCE_URL =
            SERVICE_INSTANCES_URL + "/service-instance/" + SERVICE_INSTANCE_ID;

    public static final String SERVICE_TYPE = "vCPE";

    public static final String SERVICE_SUBSCRIPTIONS_URL =
            "/service-subscriptions/service-subscription/" + SERVICE_TYPE;

    public static final String GLOBAL_CUSTOMER_ID = "DemoCustomer";

    public static final String CUSTOMERS_URL = BASE_URL_V17 + "/business/customers/customer/" + GLOBAL_CUSTOMER_ID;

    public static final String VNF_ID = "dfd02fb5-d7fb-4aac-b3c4-cd6b60058701";

    public static final String GENERIC_VNF_NAME = "EsyVnfInstantiationTest2";

    public static final String GENERIC_VNF_URL = BASE_URL_V17 + "/network/generic-vnfs/generic-vnf/";

    public static final String GENERIC_VNFS_URL = "/generic-vnfs";

    public static final String RELATED_TO_URL = "/related-to" + GENERIC_VNFS_URL;

    public static final String PLATFORM_NAME = "PLATFORM_APP_ID_1";

    public static final String LINE_OF_BUSINESS_NAME = "LINE_OF_BUSINESS_1";

    public static final String CLOUD_OWNER_NAME = "CloudOwner";

    public static final String CLOUD_REGION_NAME = "PnfSwUCloudRegion";

    public static final String TENANT_ID = "693c7729b2364a26a3ca602e6f66187d";

    public static final String TENANTS_TENANT = "/tenants/tenant/";

    public static final String ESR_VNFM_URL = BASE_URL_V17 + "/external-system/esr-vnfm-list/esr-vnfm/";

    public static final String EXTERNAL_SYSTEM_ESR_VNFM_LIST_URL = BASE_URL_V17 + "/external-system/esr-vnfm-list";

    public static final String ESR_VNFM_ID = "c5e99cee-1996-4606-b697-838d51d4e1a3";

    public static final String ESR_VIM_ID = "PnfSwUVimId";

    public static final String ESR_SYSTEM_INFO_LIST_URL = "/esr-system-info-list";

    public static final String ESR_SYSTEM_INFO_ID = "5c067098-f2e3-40f7-a7ba-155e7c61e916";

    public static final String ESR_SYSTEM_TYPE = "VNFM";

    public static final String ESR_PASSWORD = "123456";

    public static final String ESR_USERNAME = "vnfmadapter";

    public static final String ESR_SERVICE_URL = "https://so-vnfm-simulator.onap:9095/vnflcm/v1";

    public static final String ESR_VENDOR = "EST";

    public static final String ESR_TYEP = "simulator";

    public static final String SYSTEM_NAME = "vnfmSimulator";

    public static final String VSERVER_URL = "/vservers/vserver/";

    public static final String VSERVER_NAME = "CsitVServer";

    public static final String VSERVER_ID = "f84fdb9b-ad7c-49db-a08f-e443b4cbd033";

    public static final String OWNING_ENTITY_URL = BASE_URL_V17 + "/business/owning-entities/owning-entity/";

    public static final String LINES_OF_BUSINESS_URL = BASE_URL_V17 + "/business/lines-of-business/line-of-business/";

    public static final String PLATFORMS_URL = BASE_URL_V17 + "/business/platforms/platform/";

    public static final String CLOUD_REGIONS = BASE_URL_V17 + "/cloud-infrastructure/cloud-regions/cloud-region/";

    public static final String GENERIC_VNFS_URL_1 = BASE_URL_V17 + "/network/generic-vnfs";

    public static final String NODES_URL = BASE_URL_V17 + "/nodes";

    public static final String PROJECT_URL = BASE_URL_V17 + "/business/projects/project/";

    public static final String SERVICE_DESIGN_AND_CREATION_URL = BASE_URL_V17 + "/service-design-and-creation";

    private TestConstants() {}

}
