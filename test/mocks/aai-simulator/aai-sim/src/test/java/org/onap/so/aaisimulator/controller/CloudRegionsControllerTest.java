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
import static org.onap.aaisimulator.utils.Constants.VSERVER;
import static org.onap.aaisimulator.utils.TestConstants.CLOUD_OWNER_NAME;
import static org.onap.aaisimulator.utils.TestConstants.CLOUD_REGION_NAME;
import static org.onap.aaisimulator.utils.TestConstants.CUSTOMERS_URL;
import static org.onap.aaisimulator.utils.TestConstants.ESR_PASSWORD;
import static org.onap.aaisimulator.utils.TestConstants.ESR_SERVICE_URL;
import static org.onap.aaisimulator.utils.TestConstants.ESR_SYSTEM_INFO_ID;
import static org.onap.aaisimulator.utils.TestConstants.ESR_SYSTEM_INFO_LIST_URL;
import static org.onap.aaisimulator.utils.TestConstants.ESR_SYSTEM_TYPE;
import static org.onap.aaisimulator.utils.TestConstants.ESR_TYEP;
import static org.onap.aaisimulator.utils.TestConstants.ESR_USERNAME;
import static org.onap.aaisimulator.utils.TestConstants.ESR_VENDOR;
import static org.onap.aaisimulator.utils.TestConstants.GENERIC_VNF_NAME;
import static org.onap.aaisimulator.utils.TestConstants.GENERIC_VNF_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_SUBSCRIPTIONS_URL;
import static org.onap.aaisimulator.utils.TestConstants.SYSTEM_NAME;
import static org.onap.aaisimulator.utils.TestConstants.TENANTS_TENANT;
import static org.onap.aaisimulator.utils.TestConstants.TENANT_ID;
import static org.onap.aaisimulator.utils.TestConstants.VNF_ID;
import static org.onap.aaisimulator.utils.TestConstants.VSERVER_ID;
import static org.onap.aaisimulator.utils.TestConstants.VSERVER_NAME;
import static org.onap.aaisimulator.utils.TestConstants.VSERVER_URL;
import java.io.IOException;
import java.util.List;
import java.util.Optional;
import org.junit.After;
import org.junit.Test;
import org.onap.aai.domain.yang.CloudRegion;
import org.onap.aai.domain.yang.EsrSystemInfo;
import org.onap.aai.domain.yang.EsrSystemInfoList;
import org.onap.aai.domain.yang.GenericVnf;
import org.onap.aai.domain.yang.RelatedToProperty;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.aai.domain.yang.RelationshipList;
import org.onap.aai.domain.yang.Tenant;
import org.onap.aai.domain.yang.Vserver;
import org.onap.aaisimulator.models.CloudRegionKey;
import org.onap.aaisimulator.service.providers.CloudRegionCacheServiceProvider;
import org.onap.aaisimulator.service.providers.CustomerCacheServiceProvider;
import org.onap.aaisimulator.service.providers.GenericVnfCacheServiceProvider;
import org.onap.aaisimulator.utils.Constants;
import org.onap.aaisimulator.utils.TestConstants;
import org.onap.aaisimulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class CloudRegionsControllerTest extends AbstractSpringBootTest {

    private static final CloudRegionKey CLOUD_REGION_KEY = new CloudRegionKey(CLOUD_OWNER_NAME, CLOUD_REGION_NAME);

    @Autowired
    private CloudRegionCacheServiceProvider cloudRegionCacheServiceProvider;

    @Autowired
    private CustomerCacheServiceProvider customerCacheServiceProvider;

    @Autowired
    private GenericVnfCacheServiceProvider genericVnfCacheServiceProvider;

    @After
    public void after() {
        cloudRegionCacheServiceProvider.clearAll();
        customerCacheServiceProvider.clearAll();
        genericVnfCacheServiceProvider.clearAll();
    }

    @Test
    public void test_putCloudRegion_successfullyAddedToCache() throws Exception {
        final String url = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME);

        invokeCloudRegionHttpPutEndPointAndAssertResponse(url);

        final ResponseEntity<CloudRegion> response = testRestTemplateService.invokeHttpGet(url, CloudRegion.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final CloudRegion cloudRegion = response.getBody();
        assertEquals(CLOUD_OWNER_NAME, cloudRegion.getCloudOwner());
        assertEquals(CLOUD_REGION_NAME, cloudRegion.getCloudRegionId());

        assertNotNull("ResourceVersion should not be null", cloudRegion.getResourceVersion());

    }

    @Test
    public void test_getCloudRegionWithDepthValue_shouldReturnMatchedCloudRegion() throws Exception {
        final String url = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME);

        invokeCloudRegionHttpPutEndPointAndAssertResponse(url);

        final ResponseEntity<CloudRegion> response =
                testRestTemplateService.invokeHttpGet(url + "?depth=2", CloudRegion.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final CloudRegion cloudRegion = response.getBody();
        assertEquals(CLOUD_OWNER_NAME, cloudRegion.getCloudOwner());
        assertEquals(CLOUD_REGION_NAME, cloudRegion.getCloudRegionId());

        assertNotNull("ResourceVersion should not be null", cloudRegion.getResourceVersion());

    }

    @Test
    public void test_putGenericVnfRelationShipToPlatform_successfullyAddedToCache() throws Exception {

        final String url = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME);

        invokeCloudRegionHttpPutEndPointAndAssertResponse(url);

        final String relationShipUrl = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME,
                BI_DIRECTIONAL_RELATIONSHIP_LIST_URL);

        final ResponseEntity<Relationship> responseEntity = testRestTemplateService.invokeHttpPut(relationShipUrl,
                TestUtils.getGenericVnfRelationShip(), Relationship.class);
        assertEquals(HttpStatus.ACCEPTED, responseEntity.getStatusCode());

        final Optional<CloudRegion> optional = cloudRegionCacheServiceProvider.getCloudRegion(CLOUD_REGION_KEY);
        assertTrue(optional.isPresent());

        final CloudRegion actual = optional.get();

        assertNotNull(actual.getRelationshipList());
        final List<Relationship> relationshipList = actual.getRelationshipList().getRelationship();
        assertFalse("Relationship list should not be empty", relationshipList.isEmpty());
        final Relationship relationship = relationshipList.get(0);

        assertEquals(GENERIC_VNF_URL + VNF_ID, relationship.getRelatedLink());

        assertFalse("RelationshipData list should not be empty", relationship.getRelationshipData().isEmpty());
        assertFalse("RelatedToProperty list should not be empty", relationship.getRelatedToProperty().isEmpty());

        final RelationshipData relationshipData = relationship.getRelationshipData().get(0);
        assertEquals(Constants.GENERIC_VNF_VNF_ID, relationshipData.getRelationshipKey());
        assertEquals(TestConstants.VNF_ID, relationshipData.getRelationshipValue());

        final RelatedToProperty relatedToProperty = relationship.getRelatedToProperty().get(0);
        assertEquals(Constants.GENERIC_VNF_VNF_NAME, relatedToProperty.getPropertyKey());
        assertEquals(TestConstants.GENERIC_VNF_NAME, relatedToProperty.getPropertyValue());

    }

    @Test
    public void test_putTenant_successfullyAddedToCache() throws Exception {
        final String cloudRegionUrl = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME);

        invokeCloudRegionHttpPutEndPointAndAssertResponse(cloudRegionUrl);

        final String tenantUrl = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME,
                "/" + CLOUD_REGION_NAME + TENANTS_TENANT + TENANT_ID);
        addTenantAndAssertResponse(tenantUrl);

        final ResponseEntity<Tenant> response = testRestTemplateService.invokeHttpGet(tenantUrl, Tenant.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final Tenant tenant = response.getBody();
        assertEquals(TENANT_ID, tenant.getTenantId());
        assertEquals("admin", tenant.getTenantName());

        assertNotNull("ResourceVersion should not be null", tenant.getResourceVersion());

    }

    @Test
    public void test_putTenantRelationToGenericVnf_successfullyAddedToCache() throws Exception {

        addCustomerServiceAndGenericVnf();

        final String cloudRegionUrl = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME);
        invokeCloudRegionHttpPutEndPointAndAssertResponse(cloudRegionUrl);

        final String tenantUrl = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME,
                TENANTS_TENANT + TENANT_ID);
        addTenantAndAssertResponse(tenantUrl);

        final String tenantRelationShipUrl = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME,
                "/" + CLOUD_REGION_NAME, TENANTS_TENANT + TENANT_ID, RELATIONSHIP_LIST_RELATIONSHIP_URL);

        final ResponseEntity<Void> tenantRelationShipResponse = testRestTemplateService
                .invokeHttpPut(tenantRelationShipUrl, TestUtils.getGenericVnfRelatedLink(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, tenantRelationShipResponse.getStatusCode());

        final Optional<Tenant> optional = cloudRegionCacheServiceProvider.getTenant(CLOUD_REGION_KEY, TENANT_ID);

        assertTrue(optional.isPresent());
        final Tenant actualTenant = optional.get();
        final RelationshipList relationshipList = actualTenant.getRelationshipList();
        assertNotNull(relationshipList);
        assertFalse(relationshipList.getRelationship().isEmpty());

        final Relationship relationship = relationshipList.getRelationship().get(0);

        assertEquals(Constants.BELONGS_TO, relationship.getRelationshipLabel());
        assertFalse(relationship.getRelationshipData().isEmpty());
        assertEquals(1, relationship.getRelationshipData().size());

        final List<RelationshipData> relationshipDataList = relationship.getRelationshipData();

        final RelationshipData relationshipData =
                getRelationshipData(relationshipDataList, Constants.GENERIC_VNF_VNF_ID);
        assertNotNull(relationshipData);
        assertEquals(VNF_ID, relationshipData.getRelationshipValue());

        final List<RelatedToProperty> relatedToPropertyList = relationship.getRelatedToProperty();

        final RelatedToProperty property = getRelatedToProperty(relatedToPropertyList, Constants.GENERIC_VNF_VNF_NAME);
        assertNotNull(property);
        assertEquals(GENERIC_VNF_NAME, property.getPropertyValue());

        final Optional<GenericVnf> genericVnfOptional = genericVnfCacheServiceProvider.getGenericVnf(VNF_ID);
        assertTrue(genericVnfOptional.isPresent());
        final GenericVnf actualGenericVnf = genericVnfOptional.get();
        final RelationshipList relationshipListGenericVnf = actualGenericVnf.getRelationshipList();
        assertNotNull(relationshipListGenericVnf);
        assertFalse(relationshipListGenericVnf.getRelationship().isEmpty());

        final Relationship relationshipGenericVnf = relationshipListGenericVnf.getRelationship().get(0);

        assertEquals(Constants.BELONGS_TO, relationshipGenericVnf.getRelationshipLabel());
        assertFalse(relationshipGenericVnf.getRelationshipData().isEmpty());
        assertEquals(3, relationshipGenericVnf.getRelationshipData().size());

    }

    @Test
    public void test_putEsrSystemInfo_successfullyAddedToCache() throws Exception {
        final String url = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME);

        invokeCloudRegionHttpPutEndPointAndAssertResponse(url);

        final String esrSystemInfoListUrl = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME,
                "/" + CLOUD_REGION_NAME, ESR_SYSTEM_INFO_LIST_URL);

        final String esrSystemInfoUrl = esrSystemInfoListUrl + "/esr-system-info/" + ESR_SYSTEM_INFO_ID;
        final ResponseEntity<Void> esrSystemInfoResponse =
                testRestTemplateService.invokeHttpPut(esrSystemInfoUrl, TestUtils.getEsrSystemInfo(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, esrSystemInfoResponse.getStatusCode());

        final ResponseEntity<EsrSystemInfoList> response =
                testRestTemplateService.invokeHttpGet(esrSystemInfoListUrl, EsrSystemInfoList.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());
        final EsrSystemInfoList actualEsrSystemInfoList = response.getBody();

        final List<EsrSystemInfo> esrSystemInfoList = actualEsrSystemInfoList.getEsrSystemInfo();
        assertNotNull(esrSystemInfoList);
        assertEquals(1, esrSystemInfoList.size());

        final EsrSystemInfo esrSystemInfo = esrSystemInfoList.get(0);
        assertEquals(ESR_SYSTEM_INFO_ID, esrSystemInfo.getEsrSystemInfoId());
        assertEquals(SYSTEM_NAME, esrSystemInfo.getSystemName());
        assertEquals(ESR_TYEP, esrSystemInfo.getType());
        assertEquals(ESR_VENDOR, esrSystemInfo.getVendor());
        assertEquals(ESR_SERVICE_URL, esrSystemInfo.getServiceUrl());
        assertEquals(ESR_USERNAME, esrSystemInfo.getUserName());
        assertEquals(ESR_PASSWORD, esrSystemInfo.getPassword());
        assertEquals(ESR_SYSTEM_TYPE, esrSystemInfo.getSystemType());
    }

    @Test
    public void test_putVServer_successfullyAddedToCache() throws Exception {
        final String url = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME);

        invokeCloudRegionHttpPutEndPointAndAssertResponse(url);
        addCustomerServiceAndGenericVnf();

        final String tenantUrl = url + TENANTS_TENANT + TENANT_ID;
        addTenantAndAssertResponse(tenantUrl);

        final String vServerUrl = tenantUrl + VSERVER_URL + VSERVER_ID;

        final ResponseEntity<Void> vServerResponse =
                testRestTemplateService.invokeHttpPut(vServerUrl, TestUtils.getVserver(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, vServerResponse.getStatusCode());

        final ResponseEntity<Vserver> response = testRestTemplateService.invokeHttpGet(vServerUrl, Vserver.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());
        final Vserver actualVserver = response.getBody();
        assertEquals(VSERVER_NAME, actualVserver.getVserverName());
        assertEquals(VSERVER_ID, actualVserver.getVserverId());
        assertEquals("active", actualVserver.getProvStatus());
        assertNotNull(actualVserver.getRelationshipList());
        assertFalse(actualVserver.getRelationshipList().getRelationship().isEmpty());

        final Optional<GenericVnf> optional = genericVnfCacheServiceProvider.getGenericVnf(VNF_ID);
        assertTrue(optional.isPresent());
        final GenericVnf genericVnf = optional.get();
        assertNotNull(genericVnf.getRelationshipList());
        assertFalse(genericVnf.getRelationshipList().getRelationship().isEmpty());

        final Relationship expectedRelationShip = genericVnf.getRelationshipList().getRelationship().get(0);
        assertEquals(VSERVER, expectedRelationShip.getRelatedTo());
        assertNotNull(expectedRelationShip.getRelationshipData());
        assertEquals(4, expectedRelationShip.getRelationshipData().size());

        final List<RelationshipData> relationshipDataList = expectedRelationShip.getRelationshipData();
        final RelationshipData vServerrelationshipData =
                getRelationshipData(relationshipDataList, Constants.VSERVER_VSERVER_ID);
        assertNotNull(vServerrelationshipData);
        assertEquals(VSERVER_ID, vServerrelationshipData.getRelationshipValue());

        final RelationshipData cloudOwnerRelationshipData =
                getRelationshipData(relationshipDataList, Constants.CLOUD_REGION_CLOUD_OWNER);
        assertNotNull(cloudOwnerRelationshipData);
        assertEquals(CLOUD_OWNER_NAME, cloudOwnerRelationshipData.getRelationshipValue());

        final RelationshipData cloudRegionIdRelationshipData =
                getRelationshipData(relationshipDataList, Constants.CLOUD_REGION_CLOUD_REGION_ID);
        assertNotNull(cloudRegionIdRelationshipData);
        assertEquals(CLOUD_REGION_NAME, cloudRegionIdRelationshipData.getRelationshipValue());

        final RelationshipData tenantRelationshipData =
                getRelationshipData(relationshipDataList, Constants.TENANT_TENANT_ID);
        assertNotNull(tenantRelationshipData);
        assertEquals(TENANT_ID, tenantRelationshipData.getRelationshipValue());

    }

    @Test
    public void test_deleteVServer_successfullyRemoveFromCache() throws Exception {
        final String url = getUrl(TestConstants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME);

        invokeCloudRegionHttpPutEndPointAndAssertResponse(url);
        addCustomerServiceAndGenericVnf();

        final String tenantUrl = url + TENANTS_TENANT + TENANT_ID;
        addTenantAndAssertResponse(tenantUrl);

        final String vServerAddUrl = tenantUrl + VSERVER_URL + VSERVER_ID;

        final ResponseEntity<Void> vServerAddResponse =
                testRestTemplateService.invokeHttpPut(vServerAddUrl, TestUtils.getVserver(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, vServerAddResponse.getStatusCode());

        final Optional<Vserver> optional =
                cloudRegionCacheServiceProvider.getVserver(CLOUD_REGION_KEY, TENANT_ID, VSERVER_ID);
        assertTrue(optional.isPresent());
        final Vserver vserver = optional.get();

        final String vServerRemoveUrl = vServerAddUrl + "?resource-version=" + vserver.getResourceVersion();

        final ResponseEntity<Void> responseEntity =
                testRestTemplateService.invokeHttpDelete(vServerRemoveUrl, Void.class);
        assertEquals(HttpStatus.NO_CONTENT, responseEntity.getStatusCode());
        assertFalse(cloudRegionCacheServiceProvider.getVserver(CLOUD_REGION_KEY, TENANT_ID, VSERVER_ID).isPresent());


    }

    private void addTenantAndAssertResponse(final String tenantUrl) throws IOException {
        final ResponseEntity<Void> responseEntity =
                testRestTemplateService.invokeHttpPut(tenantUrl, TestUtils.getTenant(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, responseEntity.getStatusCode());
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

    private void invokeCloudRegionHttpPutEndPointAndAssertResponse(final String url) throws IOException {
        final ResponseEntity<Void> responseEntity =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getCloudRegion(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, responseEntity.getStatusCode());
    }

}
