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

import static org.onap.aaisimulator.utils.CacheName.PLATFORM_CACHE;
import static org.onap.aaisimulator.utils.Constants.PLATFORM;
import static org.onap.aaisimulator.utils.Constants.PLATFORM_PLATFORM_NAME;
import static org.onap.aaisimulator.utils.Constants.USES;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getBiDirectionalRelationShipListRelatedLink;
import java.util.Optional;
import org.onap.aai.domain.yang.Platform;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.aai.domain.yang.RelationshipList;
import org.onap.aaisimulator.cache.provider.AbstractCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Service
public class PlatformCacheServiceProviderImpl extends AbstractCacheServiceProvider
        implements PlatformCacheServiceProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(PlatformCacheServiceProviderImpl.class);

    @Autowired
    public PlatformCacheServiceProviderImpl(final CacheManager cacheManager) {
        super(cacheManager);
    }

    @Override
    public void putPlatform(final String platformName, final Platform platform) {
        LOGGER.info("Adding Platform to cache with key: {} ...", platformName);
        final Cache cache = getCache(PLATFORM_CACHE.getName());
        cache.put(platformName, platform);
    }

    @Override
    public Optional<Platform> getPlatform(final String platformName) {
        LOGGER.info("getting Platform from cache using key: {}", platformName);
        final Cache cache = getCache(PLATFORM_CACHE.getName());
        final Platform value = cache.get(platformName, Platform.class);
        if (value != null) {
            return Optional.of(value);
        }
        LOGGER.error("Unable to find Platform in cache using key:{} ", platformName);
        return Optional.empty();
    }

    @Override
    public Optional<Relationship> addRelationShip(final String platformName, final Relationship relationship,
            final String requestUri) {
        final Optional<Platform> optional = getPlatform(platformName);
        if (optional.isPresent()) {
            final Platform platform = optional.get();
            RelationshipList relationshipList = platform.getRelationshipList();
            if (relationshipList == null) {
                relationshipList = new RelationshipList();
                platform.setRelationshipList(relationshipList);
            }
            relationshipList.getRelationship().add(relationship);

            LOGGER.info("Successfully add relation to Platform with name: {}", platformName);

            final Relationship resultantRelationship = new Relationship();
            resultantRelationship.setRelatedTo(PLATFORM);
            resultantRelationship.setRelationshipLabel(USES);
            resultantRelationship.setRelatedLink(getBiDirectionalRelationShipListRelatedLink(requestUri));

            final RelationshipData relationshipData = new RelationshipData();
            relationshipData.setRelationshipKey(PLATFORM_PLATFORM_NAME);
            relationshipData.setRelationshipValue(platform.getPlatformName());
            resultantRelationship.getRelationshipData().add(relationshipData);

            return Optional.of(resultantRelationship);
        }
        LOGGER.error("Unable to find Platform ...");
        return Optional.empty();
    }

    @Override
    public void clearAll() {
        clearCache(PLATFORM_CACHE.getName());
    }

}
