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

import static org.onap.aaisimulator.utils.CacheName.CLOUD_REGION_CACHE;
import static org.onap.aaisimulator.utils.Constants.BELONGS_TO;
import static org.onap.aaisimulator.utils.Constants.CLOUD_REGION;
import static org.onap.aaisimulator.utils.Constants.CLOUD_REGION_CLOUD_OWNER;
import static org.onap.aaisimulator.utils.Constants.CLOUD_REGION_CLOUD_REGION_ID;
import static org.onap.aaisimulator.utils.Constants.CLOUD_REGION_OWNER_DEFINED_TYPE;
import static org.onap.aaisimulator.utils.Constants.HOSTED_ON;
import static org.onap.aaisimulator.utils.Constants.LOCATED_IN;
import static org.onap.aaisimulator.utils.Constants.TENANT;
import static org.onap.aaisimulator.utils.Constants.TENANT_TENANT_ID;
import static org.onap.aaisimulator.utils.Constants.TENANT_TENANT_NAME;
import static org.onap.aaisimulator.utils.Constants.VSERVER;
import static org.onap.aaisimulator.utils.Constants.VSERVER_VSERVER_ID;
import static org.onap.aaisimulator.utils.Constants.VSERVER_VSERVER_NAME;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getBiDirectionalRelationShipListRelatedLink;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getRelationShipListRelatedLink;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getTargetUrl;
import java.util.List;
import java.util.Optional;
import org.onap.aai.domain.yang.CloudRegion;
import org.onap.aai.domain.yang.EsrSystemInfo;
import org.onap.aai.domain.yang.EsrSystemInfoList;
import org.onap.aai.domain.yang.RelatedToProperty;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.aai.domain.yang.RelationshipList;
import org.onap.aai.domain.yang.Tenant;
import org.onap.aai.domain.yang.Tenants;
import org.onap.aai.domain.yang.Vserver;
import org.onap.aai.domain.yang.Vservers;
import org.onap.aaisimulator.models.CloudRegionKey;
import org.onap.aaisimulator.cache.provider.AbstractCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Service
public class CloudRegionCacheServiceProviderImpl extends AbstractCacheServiceProvider
        implements CloudRegionCacheServiceProvider {



    private static final Logger LOGGER = LoggerFactory.getLogger(CloudRegionCacheServiceProviderImpl.class);

    private final HttpRestServiceProvider httpRestServiceProvider;

    @Autowired
    public CloudRegionCacheServiceProviderImpl(final CacheManager cacheManager,
            final HttpRestServiceProvider httpRestServiceProvider) {
        super(cacheManager);
        this.httpRestServiceProvider = httpRestServiceProvider;
    }

    @Override
    public void putCloudRegion(final CloudRegionKey cloudRegionKey, final CloudRegion cloudRegion) {
        LOGGER.info("Adding CloudRegion to cache with key: {} ...", cloudRegionKey);
        final Cache cache = getCache(CLOUD_REGION_CACHE.getName());
        cache.put(cloudRegionKey, cloudRegion);

    }

    @Override
    public Optional<CloudRegion> getCloudRegion(final CloudRegionKey cloudRegionKey) {
        LOGGER.info("getting CloudRegion from cache using key: {}", cloudRegionKey);
        final Cache cache = getCache(CLOUD_REGION_CACHE.getName());
        final CloudRegion value = cache.get(cloudRegionKey, CloudRegion.class);
        if (value != null) {
            return Optional.of(value);
        }
        LOGGER.error("Unable to find CloudRegion in cache using key:{} ", cloudRegionKey);
        return Optional.empty();
    }

    @Override
    public Optional<Relationship> addRelationShip(final CloudRegionKey key, final Relationship relationship,
            final String requestUri) {
        final Optional<CloudRegion> optional = getCloudRegion(key);
        if (optional.isPresent()) {
            final CloudRegion cloudRegion = optional.get();
            RelationshipList relationshipList = cloudRegion.getRelationshipList();
            if (relationshipList == null) {
                relationshipList = new RelationshipList();
                cloudRegion.setRelationshipList(relationshipList);
            }
            relationshipList.getRelationship().add(relationship);

            LOGGER.info("Successfully added relation to CloudRegion with key: {}", key);


            final Relationship resultantRelationship = new Relationship();
            resultantRelationship.setRelatedTo(CLOUD_REGION);
            resultantRelationship.setRelationshipLabel(LOCATED_IN);
            resultantRelationship.setRelatedLink(getBiDirectionalRelationShipListRelatedLink(requestUri));

            final List<RelationshipData> relationshipDataList = resultantRelationship.getRelationshipData();
            relationshipDataList.add(getRelationshipData(CLOUD_REGION_CLOUD_OWNER, cloudRegion.getCloudOwner()));
            relationshipDataList.add(getRelationshipData(CLOUD_REGION_CLOUD_REGION_ID, cloudRegion.getCloudRegionId()));

            final List<RelatedToProperty> relatedToPropertyList = resultantRelationship.getRelatedToProperty();

            final RelatedToProperty relatedToProperty = new RelatedToProperty();
            relatedToProperty.setPropertyKey(CLOUD_REGION_OWNER_DEFINED_TYPE);
            relatedToProperty.setPropertyValue(cloudRegion.getOwnerDefinedType());
            relatedToPropertyList.add(relatedToProperty);

            return Optional.of(resultantRelationship);

        }
        LOGGER.error("Unable to find CloudRegion using key: {} ...", key);
        return Optional.empty();
    }

    @Override
    public boolean putTenant(final CloudRegionKey key, final String tenantId, final Tenant tenant) {
        final Optional<CloudRegion> optional = getCloudRegion(key);
        if (optional.isPresent()) {
            final CloudRegion cloudRegion = optional.get();
            Tenants tenants = cloudRegion.getTenants();
            if (tenants == null) {
                tenants = new Tenants();
                cloudRegion.setTenants(tenants);
            }

            final Optional<Tenant> existingTenantOptional = tenants.getTenant().stream()
                    .filter(existing -> existing.getTenantId() != null && existing.getTenantId().equals(tenantId))
                    .findFirst();

            if (!existingTenantOptional.isPresent()) {
                return tenants.getTenant().add(tenant);
            }

            LOGGER.warn("Tenant already exists ...");
            return false;
        }
        LOGGER.error("Unable to add Tenant using key: {} ...", key);
        return false;
    }

    @Override
    public Optional<Tenant> getTenant(final CloudRegionKey key, final String tenantId) {
        final Optional<CloudRegion> optional = getCloudRegion(key);
        if (optional.isPresent()) {
            final CloudRegion cloudRegion = optional.get();
            final Tenants tenants = cloudRegion.getTenants();
            if (tenants != null) {
                return tenants.getTenant().stream().filter(existing -> existing.getTenantId().equals(tenantId))
                        .findFirst();
            }
        }

        LOGGER.error("Unable to find Tenant using key: {} and tenantId: {} ...", key, tenantId);
        return Optional.empty();
    }

    @Override
    public boolean addRelationShip(final HttpHeaders incomingHeader, final String targetBaseUrl,
            final String requestUriString, final CloudRegionKey key, final String tenantId,
            final Relationship relationship) {
        try {
            final Optional<Tenant> optional = getTenant(key, tenantId);
            if (optional.isPresent()) {
                final Tenant tenant = optional.get();
                final String targetUrl = getTargetUrl(targetBaseUrl, relationship.getRelatedLink());

                final Relationship outGoingRelationShip = getRelationship(requestUriString, key, tenant);
                final Optional<Relationship> optionalRelationship = httpRestServiceProvider.put(incomingHeader,
                        outGoingRelationShip, targetUrl, Relationship.class);

                if (optionalRelationship.isPresent()) {
                    final Relationship resultantRelationship = optionalRelationship.get();
                    RelationshipList relationshipList = tenant.getRelationshipList();
                    if (relationshipList == null) {
                        relationshipList = new RelationshipList();
                        tenant.setRelationshipList(relationshipList);
                    }

                    if (relationshipList.getRelationship().add(resultantRelationship)) {
                        LOGGER.info("added relationship {} in cache successfully", resultantRelationship);
                        return true;
                    }
                }


            }
        } catch (final Exception exception) {
            LOGGER.error("Unable to add two-way relationship for CloudRegion: {} and tenant: {}", key, tenantId,
                    exception);
        }
        LOGGER.error("Unable to add relationship in cache for CloudRegion: {} and tenant: {}", key, tenantId);
        return false;
    }

    @Override
    public Optional<EsrSystemInfoList> getEsrSystemInfoList(final CloudRegionKey key) {
        final Optional<CloudRegion> optional = getCloudRegion(key);
        if (optional.isPresent()) {
            final CloudRegion cloudRegion = optional.get();
            final EsrSystemInfoList esrSystemInfoList = cloudRegion.getEsrSystemInfoList();
            if (esrSystemInfoList != null) {
                return Optional.of(esrSystemInfoList);
            }
        }
        LOGGER.error("Unable to find EsrSystemInfoList in cache for CloudRegion: {} ", key);

        return Optional.empty();
    }

    @Override
    public boolean putEsrSystemInfo(final CloudRegionKey key, final String esrSystemInfoId,
            final EsrSystemInfo esrSystemInfo) {
        final Optional<CloudRegion> optional = getCloudRegion(key);
        if (optional.isPresent()) {
            final CloudRegion cloudRegion = optional.get();
            final List<EsrSystemInfo> esrSystemInfoList = getEsrSystemInfoList(cloudRegion);

            final Optional<EsrSystemInfo> existingEsrSystemInfo =
                    esrSystemInfoList.stream().filter(existing -> existing.getEsrSystemInfoId() != null
                            && existing.getEsrSystemInfoId().equals(esrSystemInfoId)).findFirst();
            if (existingEsrSystemInfo.isPresent()) {
                LOGGER.error("EsrSystemInfo already exists {}", existingEsrSystemInfo.get());
                return false;
            }

            return esrSystemInfoList.add(esrSystemInfo);

        }
        return false;
    }

    @Override
    public boolean putVserver(final CloudRegionKey key, final String tenantId, final String vServerId,
            final Vserver vServer) {
        final Optional<Tenant> optional = getTenant(key, tenantId);
        if (optional.isPresent()) {
            final Tenant tenant = optional.get();
            Vservers vServers = tenant.getVservers();
            if (vServers == null) {
                vServers = new Vservers();
                tenant.setVservers(vServers);
            }
            final List<Vserver> vServerList = vServers.getVserver();

            final Optional<Vserver> existingVserver = vServerList.stream()
                    .filter(existing -> existing.getVserverId() != null && existing.getVserverId().equals(vServerId))
                    .findFirst();

            if (existingVserver.isPresent()) {
                LOGGER.error("Vserver already exists {}", existingVserver.get());
                return false;
            }
            return vServerList.add(vServer);

        }
        return false;
    }

    @Override
    public Optional<Vserver> getVserver(final CloudRegionKey key, final String tenantId, final String vServerId) {
        final Optional<Tenant> optional = getTenant(key, tenantId);
        if (optional.isPresent()) {
            final Tenant tenant = optional.get();
            final Vservers vServers = tenant.getVservers();
            if (vServers != null) {
                return vServers.getVserver().stream()
                        .filter(vServer -> vServer.getVserverId() != null && vServer.getVserverId().equals(vServerId))
                        .findFirst();
            }
        }
        LOGGER.error("Unable to find vServer in cache ... ");
        return Optional.empty();
    }

    @Override
    public boolean deleteVserver(final CloudRegionKey key, final String tenantId, final String vServerId,
            final String resourceVersion) {
        final Optional<Vserver> optional = getVserver(key, tenantId, vServerId);
        if (optional.isPresent()) {
            final Optional<Tenant> tenantOptional = getTenant(key, tenantId);
            if (tenantOptional.isPresent()) {
                final Tenant tenant = tenantOptional.get();
                final Vservers vServers = tenant.getVservers();
                if (vServers != null) {
                    return vServers.getVserver().removeIf(vServer -> {
                        if (vServer.getVserverId() != null && vServer.getVserverId().equals(vServerId)
                                && vServer.getResourceVersion() != null
                                && vServer.getResourceVersion().equals(resourceVersion)) {
                            LOGGER.info("Will remove Vserver from cache with vServerId: {} and resource-version: {} ",
                                    vServerId, vServer.getResourceVersion());
                            return true;
                        }
                        return false;
                    });
                }

            }

        }
        LOGGER.error(
                "Unable to find Vserver for using key: {}, tenant-id: {}, vserver-id: {} and resource-version: {} ...",
                key, tenantId, vServerId, resourceVersion);

        return false;
    }

    @Override
    public Optional<Relationship> addvServerRelationShip(final CloudRegionKey key, final String tenantId,
            final String vServerId, final Relationship relationship, final String requestUri) {
        final Optional<Vserver> optional = getVserver(key, tenantId, vServerId);
        if (optional.isPresent()) {
            final Vserver vServer = optional.get();
            RelationshipList relationshipList = vServer.getRelationshipList();
            if (relationshipList == null) {
                relationshipList = new RelationshipList();
                vServer.setRelationshipList(relationshipList);
            }
            relationshipList.getRelationship().add(relationship);
            LOGGER.info("Successfully added relation to Vserver with key: {}, tenantId: {} and vServerId: {}", key,
                    tenantId, vServerId);
            final String relatedLink = getBiDirectionalRelationShipListRelatedLink(requestUri);

            final Relationship resultantRelationship = getVserverRelationship(key, tenantId, vServer, relatedLink);

            return Optional.of(resultantRelationship);
        }

        LOGGER.error("Unable to find Vserver using key: {}, tenantId: {} and vServerId: {}...", key, tenantId,
                vServerId);
        return Optional.empty();
    }

    private Relationship getVserverRelationship(final CloudRegionKey key, final String tenantId, final Vserver vServer,
            final String relatedLink) {
        final Relationship resultantRelationship = new Relationship();
        resultantRelationship.setRelatedTo(VSERVER);
        resultantRelationship.setRelationshipLabel(HOSTED_ON);
        resultantRelationship.setRelatedLink(relatedLink);

        final List<RelationshipData> relationshipDataList = resultantRelationship.getRelationshipData();
        relationshipDataList.add(getRelationshipData(CLOUD_REGION_CLOUD_OWNER, key.getCloudOwner()));
        relationshipDataList.add(getRelationshipData(CLOUD_REGION_CLOUD_REGION_ID, key.getCloudRegionId()));
        relationshipDataList.add(getRelationshipData(TENANT_TENANT_ID, tenantId));
        relationshipDataList.add(getRelationshipData(VSERVER_VSERVER_ID, vServer.getVserverId()));

        final List<RelatedToProperty> relatedToPropertyList = resultantRelationship.getRelatedToProperty();

        final RelatedToProperty relatedToProperty = new RelatedToProperty();
        relatedToProperty.setPropertyKey(VSERVER_VSERVER_NAME);
        relatedToProperty.setPropertyValue(vServer.getVserverName());
        relatedToPropertyList.add(relatedToProperty);
        return resultantRelationship;
    }

    @Override
    public boolean addVServerRelationShip(final HttpHeaders incomingHeader, final String targetBaseUrl,
            final String requestUriString, final CloudRegionKey key, final String tenantId, final String vServerId,
            final Relationship relationship) {
        try {
            final Optional<Vserver> optional = getVserver(key, tenantId, vServerId);
            if (optional.isPresent()) {
                final Vserver vServer = optional.get();
                final String targetUrl = getTargetUrl(targetBaseUrl, relationship.getRelatedLink());
                final Relationship outGoingRelationShip = getVserverRelationship(key, tenantId, vServer,
                        getRelationShipListRelatedLink(requestUriString));
                final Optional<Relationship> optionalRelationship = httpRestServiceProvider.put(incomingHeader,
                        outGoingRelationShip, targetUrl, Relationship.class);
                if (optionalRelationship.isPresent()) {
                    final Relationship resultantRelationship = optionalRelationship.get();

                    RelationshipList relationshipList = vServer.getRelationshipList();
                    if (relationshipList == null) {
                        relationshipList = new RelationshipList();
                        vServer.setRelationshipList(relationshipList);
                    }

                    final Optional<Relationship> relationShipExists = relationshipList.getRelationship().stream()
                            .filter(relation -> relation.getRelatedTo().equals(resultantRelationship.getRelatedTo())
                                    && relation.getRelatedLink().equals(resultantRelationship.getRelatedLink()))
                            .findAny();

                    if (relationShipExists.isPresent()) {
                        LOGGER.info("relationship {} already exists in cache ", resultantRelationship);
                        return true;
                    }

                    LOGGER.info("added relationship {} in cache successfully", resultantRelationship);
                    return relationshipList.getRelationship().add(resultantRelationship);
                }

            }
        } catch (final Exception exception) {
            LOGGER.error("Unable to add two-way relationship for key: {}, tenantId: {} and vServerId: {}", key,
                    tenantId, vServerId, exception);
        }
        LOGGER.error("Unable to add Vserver relationship for key: {}, tenantId: {} and vServerId: {}...", key, tenantId,
                vServerId);
        return false;
    }

    private List<EsrSystemInfo> getEsrSystemInfoList(final CloudRegion cloudRegion) {
        EsrSystemInfoList esrSystemInfoList = cloudRegion.getEsrSystemInfoList();
        if (esrSystemInfoList == null) {
            esrSystemInfoList = new EsrSystemInfoList();
            cloudRegion.setEsrSystemInfoList(esrSystemInfoList);
        }
        return esrSystemInfoList.getEsrSystemInfo();
    }

    private Relationship getRelationship(final String requestUriString, final CloudRegionKey cloudRegionKey,
            final Tenant tenant) {
        final Relationship relationShip = new Relationship();
        relationShip.setRelatedTo(TENANT);
        relationShip.setRelationshipLabel(BELONGS_TO);
        relationShip.setRelatedLink(getRelationShipListRelatedLink(requestUriString));


        final List<RelationshipData> relationshipDataList = relationShip.getRelationshipData();
        relationshipDataList.add(getRelationshipData(CLOUD_REGION_CLOUD_OWNER, cloudRegionKey.getCloudOwner()));
        relationshipDataList.add(getRelationshipData(CLOUD_REGION_CLOUD_REGION_ID, cloudRegionKey.getCloudRegionId()));
        relationshipDataList.add(getRelationshipData(TENANT_TENANT_ID, tenant.getTenantId()));


        final RelatedToProperty relatedToProperty = new RelatedToProperty();
        relatedToProperty.setPropertyKey(TENANT_TENANT_NAME);
        relatedToProperty.setPropertyValue(tenant.getTenantName());
        relationShip.getRelatedToProperty().add(relatedToProperty);
        return relationShip;
    }

    private RelationshipData getRelationshipData(final String key, final String value) {
        final RelationshipData relationshipData = new RelationshipData();
        relationshipData.setRelationshipKey(key);
        relationshipData.setRelationshipValue(value);
        return relationshipData;
    }

    @Override
    public void clearAll() {
        clearCache(CLOUD_REGION_CACHE.getName());

    }

}
