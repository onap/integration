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

import static org.onap.aaisimulator.utils.CacheName.PROJECT_CACHE;
import static org.onap.aaisimulator.utils.Constants.PROJECT;
import static org.onap.aaisimulator.utils.Constants.PROJECT_PROJECT_NAME;
import static org.onap.aaisimulator.utils.Constants.USES;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getRelationShipListRelatedLink;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getTargetUrl;
import java.util.List;
import java.util.Optional;
import org.onap.aai.domain.yang.Project;
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
public class ProjectCacheServiceProviderImpl extends AbstractCacheServiceProvider
        implements ProjectCacheServiceProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(ProjectCacheServiceProviderImpl.class);

    private final HttpRestServiceProvider httpRestServiceProvider;

    @Autowired
    public ProjectCacheServiceProviderImpl(final CacheManager cacheManager,
            final HttpRestServiceProvider httpRestServiceProvider) {
        super(cacheManager);
        this.httpRestServiceProvider = httpRestServiceProvider;
    }

    @Override
    public void putProject(final String projectName, final Project project) {
        LOGGER.info("Adding project: {} with name to cache", project, projectName);
        final Cache cache = getCache(PROJECT_CACHE.getName());
        cache.put(projectName, project);
    }


    @Override
    public Optional<Project> getProject(final String projectName) {
        LOGGER.info("getting project from cache using key: {}", projectName);
        final Cache cache = getCache(PROJECT_CACHE.getName());
        final Project value = cache.get(projectName, Project.class);
        if (value != null) {
            return Optional.of(value);
        }
        return Optional.empty();
    }

    @Override
    public boolean addRelationShip(final HttpHeaders incomingHeader, final String targetBaseUrl,
            final String requestUriString, final String projectName, final Relationship relationship) {
        try {
            final Optional<Project> optional = getProject(projectName);

            if (optional.isPresent()) {
                final Project project = optional.get();
                final String targetUrl = getTargetUrl(targetBaseUrl, relationship.getRelatedLink());
                final Relationship outGoingRelationShip = getRelationship(requestUriString, project);

                final Optional<Relationship> optionalRelationship = httpRestServiceProvider.put(incomingHeader,
                        outGoingRelationShip, targetUrl, Relationship.class);

                if (optionalRelationship.isPresent()) {
                    final Relationship resultantRelationship = optionalRelationship.get();

                    RelationshipList relationshipList = project.getRelationshipList();
                    if (relationshipList == null) {
                        relationshipList = new RelationshipList();
                        project.setRelationshipList(relationshipList);
                    }
                    if (relationshipList.getRelationship().add(resultantRelationship)) {
                        LOGGER.info("added relationship {} in cache successfully", resultantRelationship);
                        return true;
                    }
                }
            }
        } catch (final Exception exception) {
            LOGGER.error("Unable to add two-way relationship for project name: {}", projectName, exception);
        }
        LOGGER.error("Unable to add relationship in cache for project name: {}", projectName);
        return false;
    }

    @Override
    public void clearAll() {
        clearCache(PROJECT_CACHE.getName());
    }

    private Relationship getRelationship(final String requestUriString, final Project project) {

        final Relationship relationShip = new Relationship();
        relationShip.setRelatedTo(PROJECT);
        relationShip.setRelationshipLabel(USES);
        relationShip.setRelatedLink(getRelationShipListRelatedLink(requestUriString));

        final List<RelationshipData> relationshipDataList = relationShip.getRelationshipData();

        final RelationshipData relationshipData = new RelationshipData();
        relationshipData.setRelationshipKey(PROJECT_PROJECT_NAME);
        relationshipData.setRelationshipValue(project.getProjectName());

        relationshipDataList.add(relationshipData);


        return relationShip;
    }

}
