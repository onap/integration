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

import static org.onap.aaisimulator.utils.Constants.BI_DIRECTIONAL_RELATIONSHIP_LIST_URL;
import static org.onap.aaisimulator.utils.Constants.PLATFORM;
import static org.onap.aaisimulator.utils.Constants.PLATFORMS_URL;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getResourceVersion;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.Platform;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aaisimulator.models.Format;
import org.onap.aaisimulator.models.Results;
import org.onap.aaisimulator.service.providers.PlatformCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Controller
@RequestMapping(path = PLATFORMS_URL)
public class PlatformController {
    private static final Logger LOGGER = LoggerFactory.getLogger(PlatformController.class);

    private final PlatformCacheServiceProvider cacheServiceProvider;

    @Autowired
    public PlatformController(final PlatformCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PutMapping(value = "{platform-name}", consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putPlatform(@RequestBody final Platform platform,
            @PathVariable("platform-name") final String platformName, final HttpServletRequest request) {
        LOGGER.info("Will add Platform to cache with key 'platform-name': {} ...", platform.getPlatformName());

        if (platform.getResourceVersion() == null || platform.getResourceVersion().isEmpty()) {
            platform.setResourceVersion(getResourceVersion());

        }
        cacheServiceProvider.putPlatform(platformName, platform);
        return ResponseEntity.accepted().build();
    }

    @GetMapping(value = "/{platform-name}", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getPlatform(@PathVariable("platform-name") final String platformName,
            @RequestParam(name = "depth", required = false) final Integer depth,
            @RequestParam(name = "resultIndex", required = false) final Integer resultIndex,
            @RequestParam(name = "resultSize", required = false) final Integer resultSize,
            @RequestParam(name = "format", required = false) final String format, final HttpServletRequest request) {

        LOGGER.info(
                "retrieving Platform for 'platform-name': {} with depth: {}, resultIndex: {}, resultSize:{}, format: {} ...",
                platformName, depth, resultIndex, resultSize, format);
        final Optional<Platform> optional = cacheServiceProvider.getPlatform(platformName);
        if (optional.isPresent()) {

            final Format value = Format.forValue(format);
            switch (value) {
                case RAW:
                    final Platform platform = optional.get();
                    LOGGER.info("found Platform {} in cache", platform);
                    return ResponseEntity.ok(platform);
                case COUNT:
                    final Map<String, Object> map = new HashMap<>();
                    map.put(PLATFORM, 1);
                    return ResponseEntity.ok(new Results(map));
                default:
                    break;
            }
            LOGGER.error("invalid format type :{}", format);

        }
        LOGGER.error("Unable to find Platform in cahce using {}", platformName);
        return getRequestErrorResponseEntity(request, PLATFORM);
    }

    @PutMapping(value = "/{platform-name}" + BI_DIRECTIONAL_RELATIONSHIP_LIST_URL,
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putRelationShip(@PathVariable("platform-name") final String platformName,
            @RequestBody final Relationship relationship, final HttpServletRequest request) {
        LOGGER.info("Will add {} relationship to : {} ...", relationship.getRelatedTo());

        final Optional<Relationship> optional =
                cacheServiceProvider.addRelationShip(platformName, relationship, request.getRequestURI());

        if (optional.isPresent()) {
            final Relationship resultantRelationship = optional.get();
            LOGGER.info("Relationship add, sending resultant relationship: {} in response ...", resultantRelationship);
            return ResponseEntity.accepted().body(resultantRelationship);
        }

        LOGGER.error("Couldn't add {} relationship for 'platform-name': {} ...", relationship.getRelatedTo(),
                platformName);

        return getRequestErrorResponseEntity(request, PLATFORM);

    }
}
