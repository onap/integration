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

import static org.onap.aaisimulator.utils.CacheName.CUSTOMER_CACHE;
import static org.onap.aaisimulator.utils.Constants.CUSTOMER_GLOBAL_CUSTOMER_ID;
import static org.onap.aaisimulator.utils.Constants.GENERIC_VNF;
import static org.onap.aaisimulator.utils.Constants.GENERIC_VNF_VNF_NAME;
import static org.onap.aaisimulator.utils.Constants.SERVICE_INSTANCE_SERVICE_INSTANCE_ID;
import static org.onap.aaisimulator.utils.Constants.SERVICE_INSTANCE_SERVICE_INSTANCE_NAME;
import static org.onap.aaisimulator.utils.Constants.SERVICE_SUBSCRIPTION_SERVICE_TYPE;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getBiDirectionalRelationShipListRelatedLink;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import org.onap.aai.domain.yang.Customer;
import org.onap.aai.domain.yang.RelatedToProperty;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.aai.domain.yang.RelationshipList;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aai.domain.yang.ServiceInstances;
import org.onap.aai.domain.yang.ServiceSubscription;
import org.onap.aai.domain.yang.ServiceSubscriptions;
import org.onap.aaisimulator.cache.provider.AbstractCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@Service
public class CustomerCacheServiceProviderImpl extends AbstractCacheServiceProvider
        implements CustomerCacheServiceProvider {
    private static final Logger LOGGER = LoggerFactory.getLogger(CustomerCacheServiceProviderImpl.class);

    @Autowired
    public CustomerCacheServiceProviderImpl(final CacheManager cacheManager) {
        super(cacheManager);
    }

    @Override
    public Optional<Customer> getCustomer(final String globalCustomerId) {
        LOGGER.info("getting customer from cache using key: {}", globalCustomerId);
        final Cache cache = getCache(CUSTOMER_CACHE.getName());
        final Customer value = cache.get(globalCustomerId, Customer.class);
        if (value != null) {
            return Optional.of(value);
        }
        return Optional.empty();
    }

    @Override
    public void putCustomer(final String globalCustomerId, final Customer customer) {
        LOGGER.info("Adding customer: {} with key: {} in cache ...", customer, globalCustomerId);
        final Cache cache = getCache(CUSTOMER_CACHE.getName());

        cache.put(globalCustomerId, customer);
    }

    @Override
    public Optional<ServiceSubscription> getServiceSubscription(final String globalCustomerId,
            final String serviceType) {
        LOGGER.info("getting service subscription from cache for globalCustomerId: {} and serviceType: {}",
                globalCustomerId, serviceType);

        final Cache cache = getCache(CUSTOMER_CACHE.getName());

        final Customer value = cache.get(globalCustomerId, Customer.class);

        if (value != null) {
            return Optional.ofNullable(value.getServiceSubscriptions().getServiceSubscription().stream()
                    .filter(s -> serviceType.equals(s.getServiceType())).findFirst().orElse(null));
        }
        return Optional.empty();

    }

    @Override
    public Optional<ServiceInstances> getServiceInstances(final String globalCustomerId, final String serviceType,
            final String serviceInstanceName) {

        final Cache cache = getCache(CUSTOMER_CACHE.getName());
        final Customer value = cache.get(globalCustomerId, Customer.class);

        if (value != null) {
            final Optional<ServiceSubscription> serviceSubscription = value.getServiceSubscriptions()
                    .getServiceSubscription().stream().filter(s -> serviceType.equals(s.getServiceType())).findFirst();

            if (serviceSubscription.isPresent()) {
                LOGGER.info("Found service subscription ...");
                final ServiceInstances serviceInstances = serviceSubscription.get().getServiceInstances();
                if (serviceInstances != null) {
                    final List<ServiceInstance> serviceInstancesList =
                            serviceInstances.getServiceInstance().stream()
                                    .filter(serviceInstance -> serviceInstanceName
                                            .equals(serviceInstance.getServiceInstanceName()))
                                    .collect(Collectors.toList());
                    if (serviceInstancesList != null && !serviceInstancesList.isEmpty()) {
                        LOGGER.info("Found {} service instances ", serviceInstancesList.size());
                        final ServiceInstances result = new ServiceInstances();
                        result.getServiceInstance().addAll(serviceInstancesList);
                        return Optional.of(result);

                    }
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public Optional<ServiceInstance> getServiceInstance(final String globalCustomerId, final String serviceType,
            final String serviceInstanceId) {
        final Cache cache = getCache(CUSTOMER_CACHE.getName());
        final Customer value = cache.get(globalCustomerId, Customer.class);

        if (value != null) {
            final Optional<ServiceSubscription> serviceSubscription = value.getServiceSubscriptions()
                    .getServiceSubscription().stream().filter(s -> serviceType.equals(s.getServiceType())).findFirst();

            if (serviceSubscription.isPresent()) {
                LOGGER.info("Found service subscription ...");
                final ServiceInstances serviceInstances = serviceSubscription.get().getServiceInstances();
                if (serviceInstances != null) {
                    return Optional.ofNullable(serviceInstances.getServiceInstance().stream()
                            .filter(serviceInstance -> serviceInstanceId.equals(serviceInstance.getServiceInstanceId()))
                            .findFirst().orElse(null));
                }

            }
        }
        LOGGER.error(
                "Unable to find ServiceInstance using globalCustomerId: {}, serviceType: {} and serviceInstanceId: {} ...",
                globalCustomerId, serviceType, serviceInstanceId);
        return Optional.empty();
    }

    @Override
    public boolean putServiceInstance(final String globalCustomerId, final String serviceType,
            final String serviceInstanceId, final ServiceInstance serviceInstance) {
        LOGGER.info("Adding serviceInstance: {} in cache ...", serviceInstance, globalCustomerId);

        final Cache cache = getCache(CUSTOMER_CACHE.getName());
        final Customer value = cache.get(globalCustomerId, Customer.class);

        if (value != null) {
            final Optional<ServiceSubscription> serviceSubscription = value.getServiceSubscriptions()
                    .getServiceSubscription().stream().filter(s -> serviceType.equals(s.getServiceType())).findFirst();

            if (serviceSubscription.isPresent()) {
                final ServiceInstances serviceInstances = getServiceInstances(serviceSubscription);


                if (!serviceInstances.getServiceInstance().stream()
                        .filter(existing -> serviceInstanceId.equals(existing.getServiceInstanceId())).findFirst()
                        .isPresent()) {
                    return serviceInstances.getServiceInstance().add(serviceInstance);
                }
                LOGGER.error("Service {} already exists ....", serviceInstanceId);
                return false;
            }
            LOGGER.error("Couldn't find  service subscription with serviceType: {} in cache ", serviceType);
            return false;
        }
        LOGGER.error("Couldn't find  Customer with key: {} in cache ", globalCustomerId);
        return false;
    }

    @Override
    public boolean putServiceSubscription(final String globalCustomerId, final String serviceType,
            final ServiceSubscription serviceSubscription) {

        final Optional<Customer> customerOptional = getCustomer(globalCustomerId);

        if (customerOptional.isPresent()) {
            final Customer customer = customerOptional.get();
            if (customer.getServiceSubscriptions() == null) {
                final ServiceSubscriptions serviceSubscriptions = new ServiceSubscriptions();
                customer.setServiceSubscriptions(serviceSubscriptions);
                return serviceSubscriptions.getServiceSubscription().add(serviceSubscription);
            }

            final Optional<ServiceSubscription> serviceSubscriptionOptional = customer.getServiceSubscriptions()
                    .getServiceSubscription().stream().filter(s -> serviceType.equals(s.getServiceType())).findFirst();

            if (!serviceSubscriptionOptional.isPresent()) {
                return customer.getServiceSubscriptions().getServiceSubscription().add(serviceSubscription);
            }
            LOGGER.error("ServiceSubscription already exists {}", serviceSubscriptionOptional.get().getServiceType());
            return false;
        }
        LOGGER.error("Unable to add ServiceSubscription to cache becuase customer does not exits ...");
        return false;
    }

    @Override
    public boolean patchServiceInstance(final String globalCustomerId, final String serviceType,
            final String serviceInstanceId, final ServiceInstance serviceInstance) {
        final Optional<ServiceInstance> instance = getServiceInstance(globalCustomerId, serviceType, serviceInstanceId);
        if (instance.isPresent()) {
            final ServiceInstance cachedServiceInstance = instance.get();
            LOGGER.info("Changing OrchestrationStatus from {} to {} ", cachedServiceInstance.getOrchestrationStatus(),
                    serviceInstance.getOrchestrationStatus());
            cachedServiceInstance.setOrchestrationStatus(serviceInstance.getOrchestrationStatus());
            return true;
        }
        LOGGER.error("Unable to find ServiceInstance ...");
        return false;
    }

    @Override
    public boolean deleteSericeInstance(final String globalCustomerId, final String serviceType,
            final String serviceInstanceId, final String resourceVersion) {
        final Cache cache = getCache(CUSTOMER_CACHE.getName());
        final Customer value = cache.get(globalCustomerId, Customer.class);

        if (value != null) {
            final Optional<ServiceSubscription> serviceSubscription = value.getServiceSubscriptions()
                    .getServiceSubscription().stream().filter(s -> serviceType.equals(s.getServiceType())).findFirst();

            if (serviceSubscription.isPresent()) {
                LOGGER.info("Found service subscription ...");
                final ServiceInstances serviceInstances = serviceSubscription.get().getServiceInstances();
                if (serviceInstances != null) {

                    serviceInstances.getServiceInstance().removeIf(serviceInstance -> {
                        final String existingServiceInstanceId = serviceInstance.getServiceInstanceId();
                        final String existingResourceVersion = serviceInstance.getResourceVersion();
                        if (existingServiceInstanceId != null && existingServiceInstanceId.equals(serviceInstanceId)
                                && existingResourceVersion != null && existingResourceVersion.equals(resourceVersion)) {
                            LOGGER.info("Removing ServiceInstance with serviceInstanceId: {} and resourceVersion: {}",
                                    existingServiceInstanceId, existingResourceVersion);
                            return true;
                        }
                        return false;
                    });


                    return true;
                }

            }
        }
        return false;
    }

    private ServiceInstances getServiceInstances(final Optional<ServiceSubscription> optional) {
        final ServiceSubscription serviceSubscription = optional.get();
        final ServiceInstances serviceInstances = serviceSubscription.getServiceInstances();
        if (serviceInstances == null) {
            final ServiceInstances instances = new ServiceInstances();
            serviceSubscription.setServiceInstances(instances);
            return instances;
        }
        return serviceInstances;
    }

    @Override
    public Optional<Relationship> getRelationship(final String globalCustomerId, final String serviceType,
            final String serviceInstanceId, final String vnfName) {
        final Optional<ServiceInstance> optional = getServiceInstance(globalCustomerId, serviceType, serviceInstanceId);

        if (optional.isPresent()) {
            LOGGER.info("Found service instance ...");
            final ServiceInstance serviceInstance = optional.get();
            final RelationshipList relationshipList = serviceInstance.getRelationshipList();

            if (relationshipList != null) {
                final List<Relationship> relationship = relationshipList.getRelationship();
                return relationship.stream().filter(
                        relationShip -> relationShip.getRelatedToProperty().stream().filter(relatedToProperty -> {
                            final String propertyKey = relatedToProperty.getPropertyKey();
                            final String propertyValue = relatedToProperty.getPropertyValue();
                            return GENERIC_VNF_VNF_NAME.equals(propertyKey) && propertyValue != null
                                    && propertyValue.equals(vnfName);
                        }).findFirst().isPresent()).findFirst();
            }
            LOGGER.warn("Relationship list is nulll ...");
        }
        LOGGER.error("Unable to RelationShip with property value: {}... ", vnfName);

        return Optional.empty();
    }

    @Override
    public Optional<Relationship> addRelationShip(final String globalCustomerId, final String serviceType,
            final String serviceInstanceId, final Relationship relationship, final String requestUri) {
        final Optional<ServiceInstance> optional = getServiceInstance(globalCustomerId, serviceType, serviceInstanceId);
        if (optional.isPresent()) {
            final ServiceInstance serviceInstance = optional.get();
            RelationshipList relationshipList = serviceInstance.getRelationshipList();
            if (relationshipList == null) {
                relationshipList = new RelationshipList();
                serviceInstance.setRelationshipList(relationshipList);
            }
            relationshipList.getRelationship().add(relationship);

            LOGGER.info("Successfully added relation to ServiceInstance");

            final Relationship resultantRelationship = new Relationship();
            resultantRelationship.setRelatedTo(GENERIC_VNF);
            resultantRelationship.setRelationshipLabel(relationship.getRelationshipLabel());
            resultantRelationship.setRelatedLink(getBiDirectionalRelationShipListRelatedLink(requestUri));

            final List<RelationshipData> relationshipDataList = resultantRelationship.getRelationshipData();
            relationshipDataList.add(getRelationshipData(CUSTOMER_GLOBAL_CUSTOMER_ID, globalCustomerId));
            relationshipDataList.add(getRelationshipData(SERVICE_SUBSCRIPTION_SERVICE_TYPE, serviceType));
            relationshipDataList.add(getRelationshipData(SERVICE_INSTANCE_SERVICE_INSTANCE_ID, serviceInstanceId));

            final List<RelatedToProperty> relatedToProperty = resultantRelationship.getRelatedToProperty();
            relatedToProperty.add(getRelatedToProperty(SERVICE_INSTANCE_SERVICE_INSTANCE_NAME,
                    serviceInstance.getServiceInstanceName()));

            return Optional.of(resultantRelationship);

        }
        LOGGER.error("Unable to find ServiceInstance ...");
        return Optional.empty();
    }

    @Override
    public void clearAll() {
        clearCache(CUSTOMER_CACHE.getName());
    }

    private RelatedToProperty getRelatedToProperty(final String key, final String value) {
        final RelatedToProperty relatedToProperty = new RelatedToProperty();
        relatedToProperty.setPropertyKey(key);
        relatedToProperty.setPropertyValue(value);
        return relatedToProperty;
    }

    private RelationshipData getRelationshipData(final String key, final String value) {
        final RelationshipData relationshipData = new RelationshipData();
        relationshipData.setRelationshipKey(key);
        relationshipData.setRelationshipValue(value);
        return relationshipData;
    }



}
