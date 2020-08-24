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
import static org.onap.aaisimulator.utils.Constants.X_HTTP_METHOD_OVERRIDE;
import static org.onap.aaisimulator.utils.TestConstants.CUSTOMERS_URL;
import static org.onap.aaisimulator.utils.TestConstants.GENERIC_VNF_NAME;
import static org.onap.aaisimulator.utils.TestConstants.GENERIC_VNF_URL;
import static org.onap.aaisimulator.utils.TestConstants.GLOBAL_CUSTOMER_ID;
import static org.onap.aaisimulator.utils.TestConstants.RELATED_TO_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_INSTANCES_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_ID;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_NAME;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_SUBSCRIPTIONS_URL;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_TYPE;
import static org.onap.aaisimulator.utils.TestConstants.VNF_ID;
import static org.onap.aaisimulator.utils.TestUtils.getCustomer;
import static org.onap.aaisimulator.utils.TestUtils.getServiceInstance;
import java.io.IOException;
import java.util.Optional;
import java.util.UUID;
import org.junit.After;
import org.junit.Test;
import org.onap.aai.domain.yang.Customer;
import org.onap.aai.domain.yang.GenericVnf;
import org.onap.aai.domain.yang.GenericVnfs;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aai.domain.yang.ServiceInstances;
import org.onap.aai.domain.yang.ServiceSubscription;
import org.onap.aaisimulator.service.providers.CustomerCacheServiceProvider;
import org.onap.aaisimulator.utils.RequestError;
import org.onap.aaisimulator.utils.RequestErrorResponseUtils;
import org.onap.aaisimulator.utils.ServiceException;
import org.onap.aaisimulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public class BusinessControllerTest extends AbstractSpringBootTest {

    private static final String FIREWALL_SERVICE_TYPE = "Firewall";

    private static final String ORCHESTRATION_STATUS = "Active";

    @Autowired
    private CustomerCacheServiceProvider cacheServiceProvider;

    @After
    public void after() {
        cacheServiceProvider.clearAll();
    }

    @Test
    public void test_putCustomer_successfullyAddedToCache() throws Exception {
        invokeCustomerEndPointAndAssertResponse();
        assertTrue(cacheServiceProvider.getCustomer(GLOBAL_CUSTOMER_ID).isPresent());
    }

    @Test
    public void test_getCustomer_ableToRetrieveCustomer() throws Exception {
        final String url = getUrl(CUSTOMERS_URL);

        final ResponseEntity<Void> response = testRestTemplateService.invokeHttpPut(url, getCustomer(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, response.getStatusCode());

        final ResponseEntity<Customer> actual = testRestTemplateService.invokeHttpGet(url, Customer.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final Customer actualCustomer = actual.getBody();
        assertEquals(GLOBAL_CUSTOMER_ID, actualCustomer.getGlobalCustomerId());
        assertNotNull(actualCustomer.getResourceVersion());
        assertFalse(actualCustomer.getResourceVersion().isEmpty());
    }

    @Test
    public void test_getCustomer_returnRequestError_ifCustomerNotInCache() throws Exception {
        final String url = getUrl(CUSTOMERS_URL);

        final ResponseEntity<RequestError> actual = testRestTemplateService.invokeHttpGet(url, RequestError.class);

        assertEquals(HttpStatus.NOT_FOUND, actual.getStatusCode());

        final RequestError actualError = actual.getBody();
        final ServiceException serviceException = actualError.getServiceException();

        assertNotNull(serviceException);
        assertEquals(RequestErrorResponseUtils.ERROR_MESSAGE_ID, serviceException.getMessageId());
        assertEquals(RequestErrorResponseUtils.ERROR_MESSAGE, serviceException.getText());
        assertTrue(serviceException.getVariables().contains(HttpMethod.GET.toString()));

    }

    @Test
    public void test_getServiceSubscription_ableToRetrieveServiceSubscriptionFromCache() throws Exception {
        final String url = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL);

        invokeCustomerEndPointAndAssertResponse();

        final ResponseEntity<ServiceSubscription> actual =
                testRestTemplateService.invokeHttpGet(url, ServiceSubscription.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final ServiceSubscription actualServiceSubscription = actual.getBody();
        assertEquals(SERVICE_TYPE, actualServiceSubscription.getServiceType());
        assertNotNull(actualServiceSubscription.getRelationshipList());
        assertFalse(actualServiceSubscription.getRelationshipList().getRelationship().isEmpty());
    }

    @Test
    public void test_putSericeInstance_ableToRetrieveServiceInstanceFromCache() throws Exception {

        invokeCustomerEndPointAndAssertResponse();
        invokeServiceInstanceEndPointAndAssertResponse();


        final Optional<ServiceInstance> actual =
                cacheServiceProvider.getServiceInstance(GLOBAL_CUSTOMER_ID, SERVICE_TYPE, SERVICE_INSTANCE_ID);

        assertTrue(actual.isPresent());
        final ServiceInstance actualServiceInstance = actual.get();

        assertEquals(SERVICE_INSTANCE_ID, actualServiceInstance.getServiceInstanceId());
        assertEquals(SERVICE_NAME, actualServiceInstance.getServiceInstanceName());

    }

    @Test
    public void test_getSericeInstance_usingServiceInstanceName_ableToRetrieveServiceInstanceFromCache()
            throws Exception {

        invokeCustomerEndPointAndAssertResponse();
        invokeServiceInstanceEndPointAndAssertResponse();


        final String serviceInstanceUrl = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCES_URL)
                + "?depth=2&service-instance-name=" + SERVICE_NAME;

        final ResponseEntity<ServiceInstances> actual =
                testRestTemplateService.invokeHttpGet(serviceInstanceUrl, ServiceInstances.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final ServiceInstances actualServiceInstances = actual.getBody();
        assertFalse(actualServiceInstances.getServiceInstance().isEmpty());

        assertEquals(SERVICE_NAME, actualServiceInstances.getServiceInstance().get(0).getServiceInstanceName());

    }

    @Test
    public void test_getSericeInstance_usingServiceInstanceName_returnRequestErrorIfnoServiceInstanceFound()
            throws Exception {

        invokeCustomerEndPointAndAssertResponse();

        final String serviceInstanceUrl = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCES_URL)
                + "?depth=2&service-instance-name=" + SERVICE_NAME;

        final ResponseEntity<RequestError> actual =
                testRestTemplateService.invokeHttpGet(serviceInstanceUrl, RequestError.class);

        assertEquals(HttpStatus.NOT_FOUND, actual.getStatusCode());
        assertTrue(actual.hasBody());

        assertNotNull(actual.getBody().getServiceException());

    }

    @Test
    public void test_getSericeInstance_usingServiceInstanceId_ableToRetrieveServiceInstanceFromCache()
            throws Exception {

        final String url = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCE_URL);

        invokeCustomerEndPointAndAssertResponse();
        invokeServiceInstanceEndPointAndAssertResponse();

        final ResponseEntity<ServiceInstance> actual =
                testRestTemplateService.invokeHttpGet(url, ServiceInstance.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final ServiceInstance actualServiceInstance = actual.getBody();

        assertEquals(SERVICE_NAME, actualServiceInstance.getServiceInstanceName());
        assertEquals(SERVICE_INSTANCE_ID, actualServiceInstance.getServiceInstanceId());

    }

    @Test
    public void test_getSericeInstance_usinginvalidServiceInstanceId_shouldReturnError() throws Exception {

        invokeCustomerEndPointAndAssertResponse();

        invokeServiceInstanceEndPointAndAssertResponse();


        final String invalidServiceInstanceUrl = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL,
                SERVICE_INSTANCES_URL + "/service-instance/" + UUID.randomUUID());

        final ResponseEntity<RequestError> actual =
                testRestTemplateService.invokeHttpGet(invalidServiceInstanceUrl, RequestError.class);

        assertEquals(HttpStatus.NOT_FOUND, actual.getStatusCode());

        final RequestError actualError = actual.getBody();
        final ServiceException serviceException = actualError.getServiceException();

        assertNotNull(serviceException);
        assertEquals(RequestErrorResponseUtils.ERROR_MESSAGE_ID, serviceException.getMessageId());
        assertEquals(RequestErrorResponseUtils.ERROR_MESSAGE, serviceException.getText());
        assertTrue(serviceException.getVariables().contains(HttpMethod.GET.toString()));

    }

    @Test
    public void test_getSericeInstance_usingInvalidServiceInstanceName_shouldReturnError() throws Exception {

        invokeCustomerEndPointAndAssertResponse();
        invokeServiceInstanceEndPointAndAssertResponse();


        final String serviceInstanceUrl = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCES_URL)
                + "?service-instance-name=Dummy&depth=2";

        final ResponseEntity<RequestError> actual =
                testRestTemplateService.invokeHttpGet(serviceInstanceUrl, RequestError.class);

        assertEquals(HttpStatus.NOT_FOUND, actual.getStatusCode());

        final RequestError actualError = actual.getBody();
        final ServiceException serviceException = actualError.getServiceException();

        assertNotNull(serviceException);
        assertEquals(RequestErrorResponseUtils.ERROR_MESSAGE_ID, serviceException.getMessageId());
        assertEquals(RequestErrorResponseUtils.ERROR_MESSAGE, serviceException.getText());
        assertTrue(serviceException.getVariables().contains(HttpMethod.GET.toString()));

    }

    @Test
    public void test_PathSericeInstance_usingServiceInstanceId_OrchStatusChangedInCache() throws Exception {

        final String url = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCE_URL);

        invokeCustomerEndPointAndAssertResponse();
        invokeServiceInstanceEndPointAndAssertResponse();

        final HttpHeaders httpHeaders = testRestTemplateService.getHttpHeaders();
        httpHeaders.add(X_HTTP_METHOD_OVERRIDE, HttpMethod.PATCH.toString());

        final ResponseEntity<Void> orchStatuUpdateServiceInstanceResponse = testRestTemplateService
                .invokeHttpPost(httpHeaders, url, TestUtils.getOrchStatuUpdateServiceInstance(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, orchStatuUpdateServiceInstanceResponse.getStatusCode());

        final ResponseEntity<ServiceInstance> actual =
                testRestTemplateService.invokeHttpGet(url, ServiceInstance.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final ServiceInstance actualServiceInstance = actual.getBody();

        assertEquals(SERVICE_NAME, actualServiceInstance.getServiceInstanceName());
        assertEquals(SERVICE_INSTANCE_ID, actualServiceInstance.getServiceInstanceId());
        assertEquals(ORCHESTRATION_STATUS, actualServiceInstance.getOrchestrationStatus());

    }

    @Test
    public void test_putServiceSubscription_successfullyAddedToCache() throws Exception {
        final String serviceSubscriptionurl =
                getUrl(CUSTOMERS_URL, "/service-subscriptions/service-subscription/", FIREWALL_SERVICE_TYPE);

        invokeCustomerEndPointAndAssertResponse();

        final ResponseEntity<Void> responseEntity = testRestTemplateService.invokeHttpPut(serviceSubscriptionurl,
                TestUtils.getServiceSubscription(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, responseEntity.getStatusCode());

        final ResponseEntity<ServiceSubscription> actual =
                testRestTemplateService.invokeHttpGet(serviceSubscriptionurl, ServiceSubscription.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final ServiceSubscription actualServiceSubscription = actual.getBody();
        assertEquals(FIREWALL_SERVICE_TYPE, actualServiceSubscription.getServiceType());

    }

    @Test
    public void test_putSericeInstanceRelatedTo_ableToRetrieveServiceInstanceFromCache() throws Exception {

        final String url = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCE_URL);

        invokeCustomerEndPointAndAssertResponse();

        invokeServiceInstanceEndPointAndAssertResponse();

        final String relationShipUrl = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCE_URL,
                BI_DIRECTIONAL_RELATIONSHIP_LIST_URL);

        final ResponseEntity<Relationship> responseEntity2 = testRestTemplateService.invokeHttpPut(relationShipUrl,
                TestUtils.getRelationShipJsonObject(), Relationship.class);

        assertEquals(HttpStatus.ACCEPTED, responseEntity2.getStatusCode());

        final String genericVnfUrl = getUrl(GENERIC_VNF_URL, VNF_ID);
        final ResponseEntity<Void> genericVnfResponse =
                testRestTemplateService.invokeHttpPut(genericVnfUrl, TestUtils.getGenericVnf(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, genericVnfResponse.getStatusCode());

        final ResponseEntity<GenericVnfs> actual = testRestTemplateService
                .invokeHttpGet(url + RELATED_TO_URL + "?vnf-name=" + GENERIC_VNF_NAME, GenericVnfs.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());

        assertTrue(actual.hasBody());
        final GenericVnfs genericVnfs = actual.getBody();
        assertFalse(genericVnfs.getGenericVnf().isEmpty());
        final GenericVnf genericVnf = genericVnfs.getGenericVnf().get(0);
        assertEquals(GENERIC_VNF_NAME, genericVnf.getVnfName());
    }

    @Test
    public void test_DeleteSericeInstance_ServiceInstanceRemovedFromCache() throws Exception {
        final String url = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCE_URL);

        invokeCustomerEndPointAndAssertResponse();

        invokeServiceInstanceEndPointAndAssertResponse();

        final Optional<ServiceInstance> optional =
                cacheServiceProvider.getServiceInstance(GLOBAL_CUSTOMER_ID, SERVICE_TYPE, SERVICE_INSTANCE_ID);
        assertTrue(optional.isPresent());
        final ServiceInstance serviceInstance = optional.get();

        final ResponseEntity<Void> responseEntity = testRestTemplateService
                .invokeHttpDelete(url + "?resource-version=" + serviceInstance.getResourceVersion(), Void.class);
        assertEquals(HttpStatus.NO_CONTENT, responseEntity.getStatusCode());
        assertFalse(cacheServiceProvider.getServiceInstance(GLOBAL_CUSTOMER_ID, SERVICE_TYPE, SERVICE_INSTANCE_ID)
                .isPresent());
    }

    private void invokeServiceInstanceEndPointAndAssertResponse() throws IOException {
        final String url = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCE_URL);
        final ResponseEntity<Void> responseEntity =
                testRestTemplateService.invokeHttpPut(url, getServiceInstance(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, responseEntity.getStatusCode());
    }

    private void invokeCustomerEndPointAndAssertResponse() throws Exception, IOException {
        final ResponseEntity<Void> response =
                testRestTemplateService.invokeHttpPut(getUrl(CUSTOMERS_URL), getCustomer(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, response.getStatusCode());
    }

}
