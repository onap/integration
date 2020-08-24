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
package org.onap.aaisimulator.controller;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.onap.aaisimulator.utils.Constants.RESOURCE_LINK;
import static org.onap.aaisimulator.utils.Constants.RESOURCE_TYPE;
import static org.onap.aaisimulator.utils.Constants.SERVICE_RESOURCE_TYPE;
import static org.onap.aaisimulator.utils.TestConstants.CUSTOMERS_URL;
import static org.onap.aaisimulator.utils.TestConstants.GENERIC_VNFS_URL;
import static org.onap.aaisimulator.utils.TestConstants.GENERIC_VNF_NAME;
import static org.onap.aaisimulator.utils.TestConstants.GENERIC_VNF_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_ID;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_NAME;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_SUBSCRIPTIONS_URL;
import static org.onap.aaisimulator.utils.TestConstants.VNF_ID;
import java.io.IOException;
import java.util.Map;
import org.junit.After;
import org.junit.Test;
import org.onap.aai.domain.yang.GenericVnf;
import org.onap.aai.domain.yang.GenericVnfs;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aaisimulator.models.Format;
import org.onap.aaisimulator.models.Results;
import org.onap.aaisimulator.service.providers.CustomerCacheServiceProvider;
import org.onap.aaisimulator.service.providers.NodesCacheServiceProvider;
import org.onap.aaisimulator.utils.TestConstants;
import org.onap.aaisimulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public class NodesControllerTest extends AbstractSpringBootTest {

    @Autowired
    private NodesCacheServiceProvider nodesCacheServiceProvider;

    @Autowired
    private CustomerCacheServiceProvider customerCacheServiceProvider;

    @After
    public void after() {
        nodesCacheServiceProvider.clearAll();
        customerCacheServiceProvider.clearAll();
    }

    @Test
    public void test_getNodesSericeInstance_usingServiceInstanceId_ableToRetrieveServiceInstanceFromCache()
            throws Exception {

        invokeCustomerandServiceInstanceUrls();

        final ResponseEntity<ServiceInstance> actual = testRestTemplateService
                .invokeHttpGet(getUrl(TestConstants.NODES_URL, SERVICE_INSTANCE_URL), ServiceInstance.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final ServiceInstance actualServiceInstance = actual.getBody();

        assertEquals(SERVICE_NAME, actualServiceInstance.getServiceInstanceName());
        assertEquals(SERVICE_INSTANCE_ID, actualServiceInstance.getServiceInstanceId());

    }

    @Test
    public void test_getNodesSericeInstance_usingServiceInstanceIdAndFormatPathed_ableToRetrieveServiceInstanceFromCache()
            throws Exception {

        invokeCustomerandServiceInstanceUrls();

        final ResponseEntity<Results> actual = testRestTemplateService.invokeHttpGet(
                getUrl(TestConstants.NODES_URL, SERVICE_INSTANCE_URL) + "?format=" + Format.PATHED.getValue(),
                Results.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final Results result = actual.getBody();

        assertNotNull(result.getValues());
        assertFalse(result.getValues().isEmpty());
        final Map<String, Object> actualMap = result.getValues().get(0);

        assertEquals(CUSTOMERS_URL + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCE_URL, actualMap.get(RESOURCE_LINK));
        assertEquals(SERVICE_RESOURCE_TYPE, actualMap.get(RESOURCE_TYPE));

    }

    @Test
    public void test_getNodesGenericVnfs_usingVnfName_ableToRetrieveItFromCache() throws Exception {
        invokeCustomerandServiceInstanceUrls();

        final String genericVnfUrl = getUrl(GENERIC_VNF_URL, VNF_ID);
        final ResponseEntity<Void> genericVnfResponse =
                testRestTemplateService.invokeHttpPut(genericVnfUrl, TestUtils.getGenericVnf(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, genericVnfResponse.getStatusCode());

        final String nodeGenericVnfsUrl =
                getUrl(TestConstants.NODES_URL, GENERIC_VNFS_URL) + "?vnf-name=" + GENERIC_VNF_NAME;

        final ResponseEntity<GenericVnfs> actual =
                testRestTemplateService.invokeHttpGet(nodeGenericVnfsUrl, GenericVnfs.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final GenericVnfs genericVnfs = actual.getBody();
        assertEquals(1, genericVnfs.getGenericVnf().size());

        final GenericVnf genericVnf = genericVnfs.getGenericVnf().get(0);
        assertEquals(GENERIC_VNF_NAME, genericVnf.getVnfName());
        assertEquals(VNF_ID, genericVnf.getVnfId());

    }

    private void invokeCustomerandServiceInstanceUrls() throws Exception, IOException {
        final String url = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCE_URL);

        final ResponseEntity<Void> response =
                testRestTemplateService.invokeHttpPut(getUrl(CUSTOMERS_URL), TestUtils.getCustomer(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, response.getStatusCode());

        final ResponseEntity<Void> response2 =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getServiceInstance(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, response2.getStatusCode());
    }

}
