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

import static org.onap.aaisimulator.utils.Constants.OWNING_ENTITY;
import static org.onap.aaisimulator.utils.Constants.OWNING_ENTITY_URL;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getHeaders;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getResourceVersion;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.OwningEntity;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aaisimulator.models.Format;
import org.onap.aaisimulator.models.Results;
import org.onap.aaisimulator.service.providers.OwnEntityCacheServiceProvider;
import org.onap.aaisimulator.utils.HttpServiceUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@Controller
@RequestMapping(path = OWNING_ENTITY_URL)
public class OwningEntityController {

    private static final Logger LOGGER = LoggerFactory.getLogger(OwningEntityController.class);

    private final OwnEntityCacheServiceProvider cacheServiceProvider;

    @Autowired
    public OwningEntityController(final OwnEntityCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PutMapping(value = "{owning-entity-id}", consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putOwningEntity(@RequestBody final OwningEntity owningEntity,
            @PathVariable("owning-entity-id") final String owningEntityId, final HttpServletRequest request) {
        LOGGER.info("Will add OwningEntity to cache with key 'owning-entity-id': {} ...",
                owningEntity.getOwningEntityId());

        if (owningEntity.getResourceVersion() == null || owningEntity.getResourceVersion().isEmpty()) {
            owningEntity.setResourceVersion(getResourceVersion());

        }
        cacheServiceProvider.putOwningEntity(owningEntityId, owningEntity);
        return ResponseEntity.accepted().build();
    }

    @GetMapping(value = "{owning-entity-id}", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getOwningEntity(@PathVariable("owning-entity-id") final String owningEntityId,
            @RequestParam(name = "resultIndex", required = false) final Integer resultIndex,
            @RequestParam(name = "resultSize", required = false) final Integer resultSize,
            @RequestParam(name = "format", required = false) final String format, final HttpServletRequest request) {
        LOGGER.info("retrieving owning entity for 'owning-entity-id': {} ...", owningEntityId);

        final Optional<OwningEntity> optional = cacheServiceProvider.getOwningEntity(owningEntityId);
        if (!optional.isPresent()) {
            LOGGER.error("Couldn't find {} in cache", owningEntityId);
            return getRequestErrorResponseEntity(request);
        }

        final Format value = Format.forValue(format);
        switch (value) {
            case RAW:
                final OwningEntity owningEntity = optional.get();
                LOGGER.info("found OwningEntity {} in cache", owningEntity);
                return ResponseEntity.ok(owningEntity);
            case COUNT:
                final Map<String, Object> map = new HashMap<>();
                map.put(OWNING_ENTITY, 1);
                return ResponseEntity.ok(new Results(map));
            default:
                break;
        }
        LOGGER.error("invalid format type :{}", format);
        return getRequestErrorResponseEntity(request);
    }

    @PutMapping(value = "/{owning-entity-id}/relationship-list/relationship",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putOwningEntityRelationShip(@RequestBody final Relationship relationship,
            @PathVariable("owning-entity-id") final String owningEntityId, final HttpServletRequest request) {

        LOGGER.info("adding relationship for owning-entity-id: {} ...", owningEntityId);

        if (relationship.getRelatedLink() != null) {
            final String targetBaseUrl = HttpServiceUtils.getBaseUrl(request).toString();
            final HttpHeaders incomingHeader = getHeaders(request);

            final boolean result = cacheServiceProvider.addRelationShip(incomingHeader, targetBaseUrl,
                    request.getRequestURI(), owningEntityId, relationship);
            if (result) {
                LOGGER.info("added created bi directional relationship with {}", relationship.getRelatedLink());
                return ResponseEntity.accepted().build();
            }
        }

        LOGGER.error("Unable to add relationship for related link: {}", relationship.getRelatedLink());
        return getRequestErrorResponseEntity(request);
    }

}
