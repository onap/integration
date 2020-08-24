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

import static org.onap.aaisimulator.utils.CacheName.OWNING_ENTITY_CACHE;
import static org.onap.aaisimulator.utils.Constants.BELONGS_TO;
import static org.onap.aaisimulator.utils.Constants.OWNING_ENTITY;
import static org.onap.aaisimulator.utils.Constants.OWNING_ENTITY_OWNING_ENTITY_ID;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getRelationShipListRelatedLink;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getTargetUrl;
import java.util.List;
import java.util.Optional;
import org.onap.aai.domain.yang.OwningEntity;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.aai.domain.yang.RelationshipList;
import org.onap.aaisimulator.cache.provider.AbstractCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@Service
public class OwnEntityCacheServiceProviderImpl extends AbstractCacheServiceProvider
        implements OwnEntityCacheServiceProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(OwnEntityCacheServiceProviderImpl.class);

    private final HttpRestServiceProvider httpRestServiceProvider;


    @Autowired
    public OwnEntityCacheServiceProviderImpl(final CacheManager cacheManager,
            final HttpRestServiceProvider httpRestServiceProvider) {
        super(cacheManager);
        this.httpRestServiceProvider = httpRestServiceProvider;
    }

    @Override
    public void putOwningEntity(final String owningEntityId, final OwningEntity owningEntity) {
        LOGGER.info("Adding OwningEntity: {} with name to cache", owningEntityId, owningEntity);
        final Cache cache = getCache(OWNING_ENTITY_CACHE.getName());
        cache.put(owningEntityId, owningEntity);
    }

    @Override
    public Optional<OwningEntity> getOwningEntity(final String owningEntityId) {
        LOGGER.info("getting OwningEntity from cache using key: {}", owningEntityId);
        final Cache cache = getCache(OWNING_ENTITY_CACHE.getName());
        final OwningEntity value = cache.get(owningEntityId, OwningEntity.class);
        if (value != null) {
            return Optional.of(value);
        }
        return Optional.empty();
    }

    @Override
    public boolean addRelationShip(final HttpHeaders incomingHeader, final String targetBaseUrl,
            final String requestUriString, final String owningEntityId, final Relationship relationship) {
        try {
            final Optional<OwningEntity> optional = getOwningEntity(owningEntityId);
            if (optional.isPresent()) {
                final OwningEntity owningEntity = optional.get();
                final String targetUrl = getTargetUrl(targetBaseUrl, relationship.getRelatedLink());
                final Relationship outGoingRelationShip = getRelationship(requestUriString, owningEntity);

                final Optional<Relationship> optionalRelationship = httpRestServiceProvider.put(incomingHeader,
                        outGoingRelationShip, targetUrl, Relationship.class);

                if (optionalRelationship.isPresent()) {
                    final Relationship resultantRelationship = optionalRelationship.get();

                    RelationshipList relationshipList = owningEntity.getRelationshipList();
                    if (relationshipList == null) {
                        relationshipList = new RelationshipList();
                        owningEntity.setRelationshipList(relationshipList);
                    }
                    if (relationshipList.getRelationship().add(resultantRelationship)) {
                        LOGGER.info("added relationship {} in cache successfully", resultantRelationship);
                        return true;
                    }
                }
            }

        } catch (final Exception exception) {
            LOGGER.error("Unable to add two-way relationship for owning entity id: {}", owningEntityId, exception);
        }
        LOGGER.error("Unable to add relationship in cache for owning entity id: {}", owningEntityId);
        return false;
    }

    @Override
    public void clearAll() {
        clearCache(OWNING_ENTITY_CACHE.getName());
    }

    private Relationship getRelationship(final String requestUriString, final OwningEntity owningEntity) {
        final Relationship relationShip = new Relationship();
        relationShip.setRelatedTo(OWNING_ENTITY);
        relationShip.setRelationshipLabel(BELONGS_TO);
        relationShip.setRelatedLink(getRelationShipListRelatedLink(requestUriString));

        final List<RelationshipData> relationshipDataList = relationShip.getRelationshipData();

        final RelationshipData relationshipData = new RelationshipData();
        relationshipData.setRelationshipKey(OWNING_ENTITY_OWNING_ENTITY_ID);
        relationshipData.setRelationshipValue(owningEntity.getOwningEntityId());

        relationshipDataList.add(relationshipData);


        return relationShip;
    }
}
