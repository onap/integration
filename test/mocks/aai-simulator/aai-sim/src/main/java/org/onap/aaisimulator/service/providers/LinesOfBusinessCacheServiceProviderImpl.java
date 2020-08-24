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

import static org.onap.aaisimulator.utils.CacheName.LINES_OF_BUSINESS_CACHE;
import static org.onap.aaisimulator.utils.Constants.LINE_OF_BUSINESS;
import static org.onap.aaisimulator.utils.Constants.LINE_OF_BUSINESS_LINE_OF_BUSINESS_NAME;
import static org.onap.aaisimulator.utils.Constants.USES;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getBiDirectionalRelationShipListRelatedLink;
import java.util.Optional;
import org.onap.aai.domain.yang.LineOfBusiness;
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
public class LinesOfBusinessCacheServiceProviderImpl extends AbstractCacheServiceProvider
        implements LinesOfBusinessCacheServiceProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(LinesOfBusinessCacheServiceProviderImpl.class);

    @Autowired
    public LinesOfBusinessCacheServiceProviderImpl(final CacheManager cacheManager) {
        super(cacheManager);
    }

    @Override
    public void putLineOfBusiness(final String lineOfBusinessName, final LineOfBusiness lineOfBusiness) {
        LOGGER.info("Adding LineOfBusiness to cache with key: {} ...", lineOfBusinessName);
        final Cache cache = getCache(LINES_OF_BUSINESS_CACHE.getName());
        cache.put(lineOfBusinessName, lineOfBusiness);

    }

    @Override
    public Optional<LineOfBusiness> getLineOfBusiness(final String lineOfBusinessName) {
        LOGGER.info("getting LineOfBusiness from cache using key: {}", lineOfBusinessName);
        final Cache cache = getCache(LINES_OF_BUSINESS_CACHE.getName());
        final LineOfBusiness value = cache.get(lineOfBusinessName, LineOfBusiness.class);
        if (value != null) {
            return Optional.of(value);
        }
        LOGGER.error("Unable to find LineOfBusiness in cache using key:{} ", lineOfBusinessName);
        return Optional.empty();
    }

    @Override
    public Optional<Relationship> addRelationShip(final String lineOfBusinessName, final Relationship relationship,
            final String requestUri) {
        final Optional<LineOfBusiness> optional = getLineOfBusiness(lineOfBusinessName);
        if (optional.isPresent()) {
            final LineOfBusiness lineOfBusiness = optional.get();
            RelationshipList relationshipList = lineOfBusiness.getRelationshipList();
            if (relationshipList == null) {
                relationshipList = new RelationshipList();
                lineOfBusiness.setRelationshipList(relationshipList);
            }
            relationshipList.getRelationship().add(relationship);

            LOGGER.info("Successfully added relation to LineOfBusiness with name: {}", lineOfBusinessName);
            final Relationship resultantRelationship = new Relationship();
            resultantRelationship.setRelatedTo(LINE_OF_BUSINESS);
            resultantRelationship.setRelationshipLabel(USES);
            resultantRelationship.setRelatedLink(getBiDirectionalRelationShipListRelatedLink(requestUri));

            final RelationshipData relationshipData = new RelationshipData();
            relationshipData.setRelationshipKey(LINE_OF_BUSINESS_LINE_OF_BUSINESS_NAME);
            relationshipData.setRelationshipValue(lineOfBusiness.getLineOfBusinessName());
            resultantRelationship.getRelationshipData().add(relationshipData);

            return Optional.of(resultantRelationship);

        }
        LOGGER.error("Unable to find LineOfBusiness using name: {} ...", lineOfBusinessName);
        return Optional.empty();
    }

    @Override
    public void clearAll() {
        clearCache(LINES_OF_BUSINESS_CACHE.getName());
    }

}
