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
import static org.onap.aaisimulator.utils.Constants.BI_DIRECTIONAL_RELATIONSHIP_LIST_URL;
import static org.onap.aaisimulator.utils.Constants.RELATIONSHIP_LIST_RELATIONSHIP_URL;
import static org.onap.aaisimulator.utils.Constants.X_HTTP_METHOD_OVERRIDE;
import static org.onap.aaisimulator.utils.TestConstants.CLOUD_OWNER_NAME;
import static org.onap.aaisimulator.utils.TestConstants.CLOUD_REGION_NAME;
import static org.onap.aaisimulator.utils.TestConstants.CUSTOMERS_URL;
import static org.onap.aaisimulator.utils.TestConstants.GENERIC_VNF_NAME;
import static org.onap.aaisimulator.utils.TestConstants.GENERIC_VNF_URL;
import static org.onap.aaisimulator.utils.TestConstants.GLOBAL_CUSTOMER_ID;
import static org.onap.aaisimulator.utils.TestConstants.LINE_OF_BUSINESS_NAME;
import static org.onap.aaisimulator.utils.TestConstants.PLATFORM_NAME;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_ID;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_NAME;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_SUBSCRIPTIONS_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_TYPE;
import static org.onap.aaisimulator.utils.TestConstants.VNF_ID;
import java.io.IOException;
import java.util.List;
import java.util.Optional;
import org.junit.After;
import org.junit.Test;
import org.onap.aai.domain.yang.GenericVnf;
import org.onap.aai.domain.yang.GenericVnfs;
import org.onap.aai.domain.yang.RelatedToProperty;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.aai.domain.yang.RelationshipList;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aaisimulator.service.providers.CustomerCacheServiceProvider;
import org.onap.aaisimulator.service.providers.GenericVnfCacheServiceProvider;
import org.onap.aaisimulator.service.providers.LinesOfBusinessCacheServiceProvider;
import org.onap.aaisimulator.service.providers.PlatformCacheServiceProvider;
import org.onap.aaisimulator.utils.Constants;
import org.onap.aaisimulator.utils.TestConstants;
import org.onap.aaisimulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class GenericVnfsControllerTest extends AbstractSpringBootTest {

    @Autowired
    private CustomerCacheServiceProvider customerCacheServiceProvider;

    @Autowired
    private GenericVnfCacheServiceProvider genericVnfCacheServiceProvider;

    @Autowired
    private LinesOfBusinessCacheServiceProvider linesOfBusinessCacheServiceProvider;

    @Autowired
    private PlatformCacheServiceProvider platformVnfCacheServiceProvider;

    @After
    public void after() {
        customerCacheServiceProvider.clearAll();
        genericVnfCacheServiceProvider.clearAll();
        platformVnfCacheServiceProvider.clearAll();
        linesOfBusinessCacheServiceProvider.clearAll();
    }

    @Test
    public void test_putGenericVnf_successfullyAddedToCache() throws Exception {

        final String genericVnfUrl = getUrl(GENERIC_VNF_URL, VNF_ID);
        final ResponseEntity<Void> genericVnfResponse =
                testRestTemplateService.invokeHttpPut(genericVnfUrl, TestUtils.getGenericVnf(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, genericVnfResponse.getStatusCode());

        final ResponseEntity<GenericVnf> response =
                testRestTemplateService.invokeHttpGet(genericVnfUrl, GenericVnf.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final GenericVnf actualGenericVnf = response.getBody();
        assertEquals(GENERIC_VNF_NAME, actualGenericVnf.getVnfName());
        assertEquals(VNF_ID, actualGenericVnf.getVnfId());

    }

    @Test
    public void test_putGenericVnfRelation_successfullyAddedToCache() throws Exception {

        addCustomerServiceAndGenericVnf();

        final String genericVnfRelationShipUrl = getUrl(GENERIC_VNF_URL, VNF_ID, RELATIONSHIP_LIST_RELATIONSHIP_URL);
        final ResponseEntity<Void> genericVnfRelationShipResponse = testRestTemplateService
                .invokeHttpPut(genericVnfRelationShipUrl, TestUtils.getRelationShip(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, genericVnfRelationShipResponse.getStatusCode());


        final Optional<ServiceInstance> optional =
                customerCacheServiceProvider.getServiceInstance(GLOBAL_CUSTOMER_ID, SERVICE_TYPE, SERVICE_INSTANCE_ID);

        assertTrue(optional.isPresent());

        final ServiceInstance actualServiceInstance = optional.get();
        final RelationshipList actualRelationshipList = actualServiceInstance.getRelationshipList();
        assertNotNull(actualRelationshipList);
        assertFalse(actualRelationshipList.getRelationship().isEmpty());
        final Relationship actualRelationShip = actualRelationshipList.getRelationship().get(0);

        assertEquals(Constants.COMPOSED_OF, actualRelationShip.getRelationshipLabel());
        assertEquals(GENERIC_VNF_URL + VNF_ID, actualRelationShip.getRelatedLink());


        assertFalse(actualRelationShip.getRelatedToProperty().isEmpty());
        assertFalse(actualRelationShip.getRelationshipData().isEmpty());
        final RelatedToProperty actualRelatedToProperty = actualRelationShip.getRelatedToProperty().get(0);
        final RelationshipData actualRelationshipData = actualRelationShip.getRelationshipData().get(0);

        assertEquals(Constants.GENERIC_VNF_VNF_NAME, actualRelatedToProperty.getPropertyKey());
        assertEquals(GENERIC_VNF_NAME, actualRelatedToProperty.getPropertyValue());
        assertEquals(Constants.GENERIC_VNF_VNF_ID, actualRelationshipData.getRelationshipKey());
        assertEquals(VNF_ID, actualRelationshipData.getRelationshipValue());

        final Optional<GenericVnf> genericVnfOptional = genericVnfCacheServiceProvider.getGenericVnf(VNF_ID);
        assertTrue(genericVnfOptional.isPresent());
        final GenericVnf actualGenericVnf = genericVnfOptional.get();
        final RelationshipList relationshipList = actualGenericVnf.getRelationshipList();
        assertNotNull(relationshipList);
        assertFalse(relationshipList.getRelationship().isEmpty());

        final Relationship relationship = relationshipList.getRelationship().get(0);
        assertFalse(relationship.getRelatedToProperty().isEmpty());
        assertEquals(3, relationship.getRelationshipData().size());
        assertEquals(CUSTOMERS_URL + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCE_URL, relationship.getRelatedLink());


        final List<RelatedToProperty> relatedToProperty = relationship.getRelatedToProperty();
        final RelatedToProperty firstRelatedToProperty = relatedToProperty.get(0);
        assertEquals(Constants.SERVICE_INSTANCE_SERVICE_INSTANCE_NAME, firstRelatedToProperty.getPropertyKey());
        assertEquals(SERVICE_NAME, firstRelatedToProperty.getPropertyValue());

        final List<RelationshipData> relationshipData = relationship.getRelationshipData();

        final RelationshipData globalRelationshipData =
                getRelationshipData(relationshipData, Constants.CUSTOMER_GLOBAL_CUSTOMER_ID);
        assertNotNull(globalRelationshipData);
        assertEquals(GLOBAL_CUSTOMER_ID, globalRelationshipData.getRelationshipValue());

        final RelationshipData serviceSubscriptionRelationshipData =
                getRelationshipData(relationshipData, Constants.SERVICE_SUBSCRIPTION_SERVICE_TYPE);
        assertNotNull(serviceSubscriptionRelationshipData);
        assertEquals(SERVICE_TYPE, serviceSubscriptionRelationshipData.getRelationshipValue());

        final RelationshipData serviceInstanceRelationshipData =
                getRelationshipData(relationshipData, Constants.SERVICE_INSTANCE_SERVICE_INSTANCE_ID);
        assertNotNull(serviceInstanceRelationshipData);
        assertEquals(SERVICE_INSTANCE_ID, serviceInstanceRelationshipData.getRelationshipValue());

    }

    @Test
    public void test_putGenericVnfRelationToPlatform_successfullyAddedToCache() throws Exception {
        addCustomerServiceAndGenericVnf();

        final String platformUrl = getUrl(TestConstants.PLATFORMS_URL, PLATFORM_NAME);
        final ResponseEntity<Void> platformResponse =
                testRestTemplateService.invokeHttpPut(platformUrl, TestUtils.getPlatform(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, platformResponse.getStatusCode());

        final String genericVnfRelationShipUrl = getUrl(GENERIC_VNF_URL, VNF_ID, RELATIONSHIP_LIST_RELATIONSHIP_URL);
        final ResponseEntity<Void> genericVnfRelationShipResponse = testRestTemplateService
                .invokeHttpPut(genericVnfRelationShipUrl, TestUtils.getPlatformRelatedLink(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, genericVnfRelationShipResponse.getStatusCode());

        final Optional<GenericVnf> genericVnfOptional = genericVnfCacheServiceProvider.getGenericVnf(VNF_ID);
        assertTrue(genericVnfOptional.isPresent());
        final GenericVnf actualGenericVnf = genericVnfOptional.get();
        final RelationshipList relationshipList = actualGenericVnf.getRelationshipList();
        assertNotNull(relationshipList);
        assertFalse(relationshipList.getRelationship().isEmpty());

        final Relationship relationship = relationshipList.getRelationship().get(0);

        assertEquals(Constants.USES, relationship.getRelationshipLabel());
        assertFalse(relationship.getRelationshipData().isEmpty());
        assertEquals(1, relationship.getRelationshipData().size());
        assertEquals(TestConstants.PLATFORMS_URL + PLATFORM_NAME, relationship.getRelatedLink());


        final List<RelationshipData> relationshipData = relationship.getRelationshipData();

        final RelationshipData platformRelationshipData =
                getRelationshipData(relationshipData, Constants.PLATFORM_PLATFORM_NAME);
        assertNotNull(platformRelationshipData);
        assertEquals(PLATFORM_NAME, platformRelationshipData.getRelationshipValue());

    }

    @Test
    public void test_putGenericVnfRelationToLineOfBusiness_successfullyAddedToCache() throws Exception {
        addCustomerServiceAndGenericVnf();

        final String url = getUrl(TestConstants.LINES_OF_BUSINESS_URL, LINE_OF_BUSINESS_NAME);
        final ResponseEntity<Void> responseEntity =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getLineOfBusiness(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, responseEntity.getStatusCode());

        final String genericVnfRelationShipUrl = getUrl(GENERIC_VNF_URL, VNF_ID, RELATIONSHIP_LIST_RELATIONSHIP_URL);
        final ResponseEntity<Void> genericVnfRelationShipResponse = testRestTemplateService
                .invokeHttpPut(genericVnfRelationShipUrl, TestUtils.getLineOfBusinessRelatedLink(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, genericVnfRelationShipResponse.getStatusCode());

        final Optional<GenericVnf> genericVnfOptional = genericVnfCacheServiceProvider.getGenericVnf(VNF_ID);
        assertTrue(genericVnfOptional.isPresent());
        final GenericVnf actualGenericVnf = genericVnfOptional.get();
        final RelationshipList relationshipList = actualGenericVnf.getRelationshipList();
        assertNotNull(relationshipList);
        assertFalse(relationshipList.getRelationship().isEmpty());

        final Relationship relationship = relationshipList.getRelationship().get(0);

        assertEquals(Constants.USES, relationship.getRelationshipLabel());
        assertEquals(TestConstants.LINES_OF_BUSINESS_URL + LINE_OF_BUSINESS_NAME, relationship.getRelatedLink());

        assertFalse(relationship.getRelationshipData().isEmpty());
        assertEquals(1, relationship.getRelationshipData().size());

        final List<RelationshipData> relationshipData = relationship.getRelationshipData();

        final RelationshipData lineOfBusinessRelationshipData =
                getRelationshipData(relationshipData, Constants.LINE_OF_BUSINESS_LINE_OF_BUSINESS_NAME);
        assertNotNull(lineOfBusinessRelationshipData);
        assertEquals(LINE_OF_BUSINESS_NAME, lineOfBusinessRelationshipData.getRelationshipValue());

    }

    @Test
    public void test_putGenericVnfRelationToCloudRegion_successfullyAddedToCache() throws Exception {
        addCustomerServiceAndGenericVnf();

        final String url = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME);

        final ResponseEntity<Void> responseEntity =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getCloudRegion(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, responseEntity.getStatusCode());

        final String genericVnfRelationShipUrl = getUrl(GENERIC_VNF_URL, VNF_ID, RELATIONSHIP_LIST_RELATIONSHIP_URL);
        final ResponseEntity<Void> genericVnfRelationShipResponse = testRestTemplateService
                .invokeHttpPut(genericVnfRelationShipUrl, TestUtils.getCloudRegionRelatedLink(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, genericVnfRelationShipResponse.getStatusCode());

        final Optional<GenericVnf> genericVnfOptional = genericVnfCacheServiceProvider.getGenericVnf(VNF_ID);
        assertTrue(genericVnfOptional.isPresent());
        final GenericVnf actualGenericVnf = genericVnfOptional.get();
        final RelationshipList relationshipList = actualGenericVnf.getRelationshipList();
        assertNotNull(relationshipList);
        assertFalse(relationshipList.getRelationship().isEmpty());

        final Relationship relationship = relationshipList.getRelationship().get(0);

        assertEquals(Constants.LOCATED_IN, relationship.getRelationshipLabel());
        assertEquals(TestConstants.CLOUD_REGIONS + CLOUD_OWNER_NAME + "/" + CLOUD_REGION_NAME,
                relationship.getRelatedLink());

        assertFalse(relationship.getRelationshipData().isEmpty());
        assertEquals(2, relationship.getRelationshipData().size());

        final List<RelationshipData> relationshipDataList = relationship.getRelationshipData();

        final RelationshipData cloudOwnerRelationshipData =
                getRelationshipData(relationshipDataList, Constants.CLOUD_REGION_CLOUD_OWNER);
        assertNotNull(cloudOwnerRelationshipData);
        assertEquals(CLOUD_OWNER_NAME, cloudOwnerRelationshipData.getRelationshipValue());

        final RelationshipData cloudRegionIdRelationshipData =
                getRelationshipData(relationshipDataList, Constants.CLOUD_REGION_CLOUD_REGION_ID);
        assertNotNull(cloudRegionIdRelationshipData);
        assertEquals(CLOUD_REGION_NAME, cloudRegionIdRelationshipData.getRelationshipValue());

        final List<RelatedToProperty> relatedToPropertyList = relationship.getRelatedToProperty();

        final RelatedToProperty cloudRegionOwnerDefinedTypeProperty =
                getRelatedToProperty(relatedToPropertyList, Constants.CLOUD_REGION_OWNER_DEFINED_TYPE);
        assertNotNull(cloudRegionOwnerDefinedTypeProperty);
        assertEquals("OwnerType", cloudRegionOwnerDefinedTypeProperty.getPropertyValue());

    }

    @Test
    public void test_putBiDirectionalRelationShip_successfullyAddedToCache() throws Exception {
        addCustomerServiceAndGenericVnf();

        final String relationShipUrl = getUrl(GENERIC_VNF_URL, VNF_ID, BI_DIRECTIONAL_RELATIONSHIP_LIST_URL);

        final ResponseEntity<Relationship> responseEntity = testRestTemplateService.invokeHttpPut(relationShipUrl,
                TestUtils.getTenantRelationShip(), Relationship.class);
        assertEquals(HttpStatus.ACCEPTED, responseEntity.getStatusCode());

        final Optional<GenericVnf> optional = genericVnfCacheServiceProvider.getGenericVnf(VNF_ID);
        assertTrue(optional.isPresent());

        final GenericVnf actual = optional.get();

        assertNotNull(actual.getRelationshipList());
        final List<Relationship> relationshipList = actual.getRelationshipList().getRelationship();
        assertFalse("Relationship list should not be empty", relationshipList.isEmpty());
        final Relationship relationship = relationshipList.get(0);

        assertFalse("RelationshipData list should not be empty", relationship.getRelationshipData().isEmpty());
        assertFalse("RelatedToProperty list should not be empty", relationship.getRelatedToProperty().isEmpty());
    }

    @Test
    public void test_patchGenericVnf_usingVnfId_OrchStatusChangedInCache() throws Exception {
        addCustomerServiceAndGenericVnf();

        final HttpHeaders httpHeaders = testRestTemplateService.getHttpHeaders();
        httpHeaders.add(X_HTTP_METHOD_OVERRIDE, HttpMethod.PATCH.toString());
        httpHeaders.remove(HttpHeaders.CONTENT_TYPE);
        httpHeaders.add(HttpHeaders.CONTENT_TYPE, Constants.APPLICATION_MERGE_PATCH_JSON);

        final String genericVnfUrl = getUrl(GENERIC_VNF_URL, VNF_ID);
        final ResponseEntity<Void> orchStatuUpdateServiceInstanceResponse = testRestTemplateService
                .invokeHttpPost(httpHeaders, genericVnfUrl, TestUtils.getGenericVnfOrchStatuUpdate(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, orchStatuUpdateServiceInstanceResponse.getStatusCode());

        final ResponseEntity<GenericVnf> response =
                testRestTemplateService.invokeHttpGet(genericVnfUrl, GenericVnf.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final GenericVnf actualGenericVnf = response.getBody();
        assertEquals(GENERIC_VNF_NAME, actualGenericVnf.getVnfName());
        assertEquals(VNF_ID, actualGenericVnf.getVnfId());
        assertEquals("Assigned", actualGenericVnf.getOrchestrationStatus());

    }

    @Test
    public void test_getGenericVnfs_usingSelfLink_getAllGenericVnfsInCache() throws Exception {

        addCustomerServiceAndGenericVnf();

        final String selfLink = "http://localhost:9921/generic-vnf/" + VNF_ID;
        final String url = getUrl(TestConstants.GENERIC_VNFS_URL_1) + "?selflink=" + selfLink;
        final ResponseEntity<GenericVnfs> response = testRestTemplateService.invokeHttpGet(url, GenericVnfs.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final GenericVnfs actualGenericVnfs = response.getBody();
        final List<GenericVnf> genericVnfList = actualGenericVnfs.getGenericVnf();
        assertNotNull(genericVnfList);
        assertEquals(1, genericVnfList.size());
        final GenericVnf actualGenericVnf = genericVnfList.get(0);
        assertEquals(selfLink, actualGenericVnf.getSelflink());
        assertEquals(GENERIC_VNF_NAME, actualGenericVnf.getVnfName());
        assertEquals(VNF_ID, actualGenericVnf.getVnfId());
    }

    @Test
    public void test_deleteGenericVnf_usingVnfIdAndResourceVersion_removedFromCache() throws Exception {

        addCustomerServiceAndGenericVnf();

        final Optional<GenericVnf> genericVnfOptional = genericVnfCacheServiceProvider.getGenericVnf(VNF_ID);
        assertTrue(genericVnfOptional.isPresent());
        final GenericVnf genericVnf = genericVnfOptional.get();

        final String genericVnfDeleteUrl =
                getUrl(GENERIC_VNF_URL, genericVnf.getVnfId()) + "?resource-version=" + genericVnf.getResourceVersion();

        final ResponseEntity<Void> responseEntity =
                testRestTemplateService.invokeHttpDelete(genericVnfDeleteUrl, Void.class);
        assertEquals(HttpStatus.NO_CONTENT, responseEntity.getStatusCode());
        assertFalse(genericVnfCacheServiceProvider.getGenericVnf(VNF_ID).isPresent());

    }

    private void addCustomerServiceAndGenericVnf() throws Exception, IOException {
        final ResponseEntity<Void> customerResponse =
                testRestTemplateService.invokeHttpPut(getUrl(CUSTOMERS_URL), TestUtils.getCustomer(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, customerResponse.getStatusCode());

        final String serviceInstanceUrl = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCE_URL);
        final ResponseEntity<Void> serviceInstanceResponse =
                testRestTemplateService.invokeHttpPut(serviceInstanceUrl, TestUtils.getServiceInstance(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, serviceInstanceResponse.getStatusCode());

        final String genericVnfUrl = getUrl(GENERIC_VNF_URL, VNF_ID);
        final ResponseEntity<Void> genericVnfResponse =
                testRestTemplateService.invokeHttpPut(genericVnfUrl, TestUtils.getGenericVnf(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, genericVnfResponse.getStatusCode());

    }


}
