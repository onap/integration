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
import static org.onap.aaisimulator.utils.Constants.RELATIONSHIP_LIST_RELATIONSHIP_URL;
import static org.onap.aaisimulator.utils.TestConstants.CUSTOMERS_URL;
import static org.onap.aaisimulator.utils.TestConstants.GLOBAL_CUSTOMER_ID;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_ID;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_SUBSCRIPTIONS_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_TYPE;
import java.io.IOException;
import java.util.List;
import java.util.Optional;
import org.junit.After;
import org.junit.Test;
import org.onap.aai.domain.yang.Project;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aaisimulator.models.Results;
import org.onap.aaisimulator.service.providers.CustomerCacheServiceProvider;
import org.onap.aaisimulator.service.providers.ProjectCacheServiceProvider;
import org.onap.aaisimulator.utils.Constants;
import org.onap.aaisimulator.utils.TestConstants;
import org.onap.aaisimulator.utils.TestRestTemplateService;
import org.onap.aaisimulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public class ProjectControllerTest extends AbstractSpringBootTest {

    private static final String PROJECT_NAME_VALUE = "PROJECT_NAME_VALUE";

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplateService testRestTemplateService;

    @Autowired
    private ProjectCacheServiceProvider cacheServiceProvider;

    @Autowired
    private CustomerCacheServiceProvider customerCacheServiceProvider;

    @After
    public void after() {
        cacheServiceProvider.clearAll();
        customerCacheServiceProvider.clearAll();
    }

    @Test
    public void test_putProject_successfullyAddedToCache() throws Exception {
        final String url = getUrl(TestConstants.PROJECT_URL, PROJECT_NAME_VALUE);
        final ResponseEntity<Void> actual =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getBusinessProject(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final ResponseEntity<Project> actualResponse = testRestTemplateService.invokeHttpGet(url, Project.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final Project actualProject = actualResponse.getBody();
        assertEquals(PROJECT_NAME_VALUE, actualProject.getProjectName());
        assertNotNull(actualProject.getResourceVersion());

    }

    @Test
    public void test_putProjectRelationShip_successfullyAddedToCache() throws Exception {
        addCustomerAndServiceInstance();

        final String url = getUrl(TestConstants.PROJECT_URL, PROJECT_NAME_VALUE);
        final ResponseEntity<Void> actual =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getBusinessProject(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final String projectRelationshipUrl =
                getUrl(TestConstants.PROJECT_URL, PROJECT_NAME_VALUE, RELATIONSHIP_LIST_RELATIONSHIP_URL);

        final ResponseEntity<Void> putResponse = testRestTemplateService.invokeHttpPut(projectRelationshipUrl,
                TestUtils.getBusinessProjectRelationship(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, putResponse.getStatusCode());

        final ResponseEntity<Project> actualResponse = testRestTemplateService.invokeHttpGet(url, Project.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final Project actualProject = actualResponse.getBody();
        assertEquals(PROJECT_NAME_VALUE, actualProject.getProjectName());
        assertNotNull(actualProject.getRelationshipList());
        assertFalse(actualProject.getRelationshipList().getRelationship().isEmpty());
        assertNotNull(actualProject.getRelationshipList().getRelationship().get(0));

        final Relationship actualRelationship = actualProject.getRelationshipList().getRelationship().get(0);
        final List<RelationshipData> relationshipDataList = actualRelationship.getRelationshipData();
        assertEquals(Constants.USES, actualRelationship.getRelationshipLabel());

        assertFalse(relationshipDataList.isEmpty());
        assertEquals(3, relationshipDataList.size());

        final RelationshipData globalRelationshipData =
                getRelationshipData(relationshipDataList, Constants.CUSTOMER_GLOBAL_CUSTOMER_ID);
        assertNotNull(globalRelationshipData);
        assertEquals(GLOBAL_CUSTOMER_ID, globalRelationshipData.getRelationshipValue());

        final RelationshipData serviceSubscriptionRelationshipData =
                getRelationshipData(relationshipDataList, Constants.SERVICE_SUBSCRIPTION_SERVICE_TYPE);
        assertNotNull(serviceSubscriptionRelationshipData);
        assertEquals(SERVICE_TYPE, serviceSubscriptionRelationshipData.getRelationshipValue());

        final RelationshipData serviceInstanceRelationshipData =
                getRelationshipData(relationshipDataList, Constants.SERVICE_INSTANCE_SERVICE_INSTANCE_ID);
        assertNotNull(serviceInstanceRelationshipData);
        assertEquals(SERVICE_INSTANCE_ID, serviceInstanceRelationshipData.getRelationshipValue());

        final Optional<ServiceInstance> optional =
                customerCacheServiceProvider.getServiceInstance(GLOBAL_CUSTOMER_ID, SERVICE_TYPE, SERVICE_INSTANCE_ID);
        assertTrue(optional.isPresent());

        final ServiceInstance serviceInstance = optional.get();

        assertNotNull(serviceInstance.getRelationshipList());
        final List<Relationship> serviceRelationshipList = serviceInstance.getRelationshipList().getRelationship();
        assertFalse(serviceRelationshipList.isEmpty());
        assertEquals(1, serviceRelationshipList.size());
        final Relationship relationship = serviceRelationshipList.get(0);
        assertEquals(Constants.USES, relationship.getRelationshipLabel());
        assertEquals(TestConstants.PROJECT_URL + PROJECT_NAME_VALUE, relationship.getRelatedLink());


        final List<RelationshipData> serviceRelationshipDataList = serviceRelationshipList.get(0).getRelationshipData();
        assertFalse(serviceRelationshipDataList.isEmpty());
        assertEquals(1, serviceRelationshipDataList.size());

        final RelationshipData projectRelationshipData =
                getRelationshipData(serviceRelationshipDataList, Constants.PROJECT_PROJECT_NAME);
        assertNotNull(projectRelationshipData);
        assertEquals(PROJECT_NAME_VALUE, projectRelationshipData.getRelationshipValue());

    }

    @Test
    public void test_getProjectCount_correctResult() throws Exception {
        final String url = getUrl(TestConstants.PROJECT_URL, PROJECT_NAME_VALUE);
        final ResponseEntity<Void> actual =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getBusinessProject(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final ResponseEntity<Results> actualResponse =
                testRestTemplateService.invokeHttpGet(url + "?resultIndex=0&resultSize=1&format=count", Results.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final Results result = actualResponse.getBody();
        assertNotNull(result.getValues());
        assertFalse(result.getValues().isEmpty());
        assertEquals(1, result.getValues().get(0).get(Constants.PROJECT));
    }


    private void addCustomerAndServiceInstance() throws Exception, IOException {
        final ResponseEntity<Void> customerResponse =
                testRestTemplateService.invokeHttpPut(getUrl(CUSTOMERS_URL), TestUtils.getCustomer(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, customerResponse.getStatusCode());

        final String serviceInstanceUrl = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCE_URL);
        final ResponseEntity<Void> serviceInstanceResponse =
                testRestTemplateService.invokeHttpPut(serviceInstanceUrl, TestUtils.getServiceInstance(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, serviceInstanceResponse.getStatusCode());

    }

}
