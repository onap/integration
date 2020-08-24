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
import static org.onap.aaisimulator.utils.TestConstants.ESR_PASSWORD;
import static org.onap.aaisimulator.utils.TestConstants.ESR_SERVICE_URL;
import static org.onap.aaisimulator.utils.TestConstants.ESR_SYSTEM_INFO_ID;
import static org.onap.aaisimulator.utils.TestConstants.ESR_SYSTEM_INFO_LIST_URL;
import static org.onap.aaisimulator.utils.TestConstants.ESR_SYSTEM_TYPE;
import static org.onap.aaisimulator.utils.TestConstants.ESR_TYEP;
import static org.onap.aaisimulator.utils.TestConstants.ESR_USERNAME;
import static org.onap.aaisimulator.utils.TestConstants.ESR_VENDOR;
import static org.onap.aaisimulator.utils.TestConstants.ESR_VIM_ID;
import static org.onap.aaisimulator.utils.TestConstants.ESR_VNFM_ID;
import static org.onap.aaisimulator.utils.TestConstants.ESR_VNFM_URL;
import static org.onap.aaisimulator.utils.TestConstants.GENERIC_VNF_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_SUBSCRIPTIONS_URL;
import static org.onap.aaisimulator.utils.TestConstants.SYSTEM_NAME;
import static org.onap.aaisimulator.utils.TestConstants.VNF_ID;
import java.io.IOException;
import java.util.List;
import java.util.Optional;
import org.junit.After;
import org.junit.Test;
import org.onap.aai.domain.yang.EsrSystemInfo;
import org.onap.aai.domain.yang.EsrSystemInfoList;
import org.onap.aai.domain.yang.EsrVnfm;
import org.onap.aai.domain.yang.EsrVnfmList;
import org.onap.aai.domain.yang.GenericVnf;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.aai.domain.yang.RelationshipList;
import org.onap.aaisimulator.service.providers.ExternalSystemCacheServiceProvider;
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
public class ExternalSystemEsrControllerTest extends AbstractSpringBootTest {

    @Autowired
    private ExternalSystemCacheServiceProvider externalSystemCacheServiceProvider;


    @Autowired
    private GenericVnfCacheServiceProvider genericVnfCacheServiceProvider;

    @After
    public void after() {
        externalSystemCacheServiceProvider.clearAll();
        genericVnfCacheServiceProvider.clearAll();
    }

    @Test
    public void test_putEsrVnfm_successfullyAddedToCache() throws Exception {
        final String esrVnfmUrl = getUrl(ESR_VNFM_URL, ESR_VNFM_ID);
        addEsrVnfmAndAssertResponse(esrVnfmUrl);

        final ResponseEntity<EsrVnfm> response = testRestTemplateService.invokeHttpGet(esrVnfmUrl, EsrVnfm.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final EsrVnfm actualEsrVnfm = response.getBody();
        assertEquals(ESR_VNFM_ID, actualEsrVnfm.getVnfmId());
        assertEquals(ESR_VIM_ID, actualEsrVnfm.getVimId());

    }

    @Test
    public void test_getEsrVnfmList_getAllEsrVnfmsFromCache() throws Exception {
        final String esrVnfmUrl = getUrl(ESR_VNFM_URL, ESR_VNFM_ID);
        addEsrVnfmAndAssertResponse(esrVnfmUrl);

        final String esrVnfmListUrl = getUrl(TestConstants.EXTERNAL_SYSTEM_ESR_VNFM_LIST_URL);
        final ResponseEntity<EsrVnfmList> response =
                testRestTemplateService.invokeHttpGet(esrVnfmListUrl, EsrVnfmList.class);

        assertTrue(response.hasBody());

        final EsrVnfmList actualEsrVnfmList = response.getBody();

        final List<EsrVnfm> esrVnfmList = actualEsrVnfmList.getEsrVnfm();
        assertNotNull(esrVnfmList);
        assertEquals(1, esrVnfmList.size());
        final EsrVnfm actualEsrVnfm = esrVnfmList.get(0);
        assertEquals(ESR_VNFM_ID, actualEsrVnfm.getVnfmId());
        assertEquals(ESR_VIM_ID, actualEsrVnfm.getVimId());

    }

    @Test
    public void test_putEsrSystemInfo_successfullyAddedToCache() throws Exception {
        final String esrVnfmUrl = getUrl(ESR_VNFM_URL, ESR_VNFM_ID);
        addEsrVnfmAndAssertResponse(esrVnfmUrl);
        final String esrSystemInfoListUrl = getUrl(ESR_VNFM_URL, ESR_VNFM_ID, ESR_SYSTEM_INFO_LIST_URL);

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
    public void test_putEsrRelationToGenericVnfm_successfullyAddedToCache() throws Exception {
        final String esrVnfmUrl = getUrl(ESR_VNFM_URL, ESR_VNFM_ID);

        addEsrVnfmAndAssertResponse(esrVnfmUrl);
        addCustomerServiceAndGenericVnf();

        final String relationShipUrl = esrVnfmUrl + RELATIONSHIP_LIST_RELATIONSHIP_URL;

        final ResponseEntity<Void> response = testRestTemplateService.invokeHttpPut(relationShipUrl,
                TestUtils.getGenericVnfRelatedLink(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, response.getStatusCode());

        final Optional<EsrVnfm> optional = externalSystemCacheServiceProvider.getEsrVnfm(ESR_VNFM_ID);
        assertTrue(optional.isPresent());

        final EsrVnfm actualEsrVnfm = optional.get();
        final RelationshipList relationshipList = actualEsrVnfm.getRelationshipList();
        assertNotNull(relationshipList);
        assertFalse(relationshipList.getRelationship().isEmpty());

        final Relationship relationship = relationshipList.getRelationship().get(0);

        assertEquals(Constants.DEPENDS_ON, relationship.getRelationshipLabel());
        assertFalse(relationship.getRelationshipData().isEmpty());
        assertEquals(1, relationship.getRelationshipData().size());

        final RelationshipData relationshipData =
                getRelationshipData(relationship.getRelationshipData(), Constants.GENERIC_VNF_VNF_ID);
        assertNotNull(relationshipData);
        assertEquals(VNF_ID, relationshipData.getRelationshipValue());

        final Optional<GenericVnf> genericVnfOptional = genericVnfCacheServiceProvider.getGenericVnf(VNF_ID);
        assertTrue(genericVnfOptional.isPresent());
        final GenericVnf actualGenericVnf = genericVnfOptional.get();
        final RelationshipList relationshipListGenericVnf = actualGenericVnf.getRelationshipList();
        assertNotNull(relationshipListGenericVnf);
        assertFalse(relationshipListGenericVnf.getRelationship().isEmpty());

        final Relationship relationshipGenericVnf = relationshipListGenericVnf.getRelationship().get(0);

        assertEquals(Constants.DEPENDS_ON, relationshipGenericVnf.getRelationshipLabel());
        assertFalse(relationshipGenericVnf.getRelationshipData().isEmpty());
        assertEquals(1, relationshipGenericVnf.getRelationshipData().size());

        final RelationshipData esrRelationshipData =
                getRelationshipData(relationshipGenericVnf.getRelationshipData(), Constants.ESR_VNFM_VNFM_ID);
        assertNotNull(esrRelationshipData);
        assertEquals(ESR_VNFM_ID, esrRelationshipData.getRelationshipValue());


    }

    private void addEsrVnfmAndAssertResponse(final String esrVnfmUrl) throws IOException {
        final ResponseEntity<Void> esrVnfmResponse =
                testRestTemplateService.invokeHttpPut(esrVnfmUrl, TestUtils.getEsrVnfm(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, esrVnfmResponse.getStatusCode());
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
