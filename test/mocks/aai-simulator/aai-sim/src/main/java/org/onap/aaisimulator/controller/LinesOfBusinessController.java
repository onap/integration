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
import static org.onap.aaisimulator.utils.Constants.LINES_OF_BUSINESS_URL;
import static org.onap.aaisimulator.utils.Constants.LINE_OF_BUSINESS;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getResourceVersion;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.LineOfBusiness;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aaisimulator.models.Format;
import org.onap.aaisimulator.models.Results;
import org.onap.aaisimulator.service.providers.LinesOfBusinessCacheServiceProvider;
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
@RequestMapping(path = LINES_OF_BUSINESS_URL)
public class LinesOfBusinessController {
    private static final Logger LOGGER = LoggerFactory.getLogger(LinesOfBusinessController.class);

    private final LinesOfBusinessCacheServiceProvider cacheServiceProvider;

    @Autowired
    public LinesOfBusinessController(final LinesOfBusinessCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PutMapping(value = "{line-of-business-name}", consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putLineOfBusiness(@RequestBody final LineOfBusiness lineOfBusiness,
            @PathVariable("line-of-business-name") final String lineOfBusinessName, final HttpServletRequest request) {

        LOGGER.info("Will add LineOfBusiness to cache with key 'line-of-business-name': {} ...",
                lineOfBusiness.getLineOfBusinessName());

        if (lineOfBusiness.getResourceVersion() == null || lineOfBusiness.getResourceVersion().isEmpty()) {
            lineOfBusiness.setResourceVersion(getResourceVersion());

        }
        cacheServiceProvider.putLineOfBusiness(lineOfBusinessName, lineOfBusiness);
        return ResponseEntity.accepted().build();
    }


    @GetMapping(value = "{line-of-business-name}", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getLineOfBusiness(@PathVariable("line-of-business-name") final String lineOfBusinessName,
            @RequestParam(name = "depth", required = false) final Integer depth,
            @RequestParam(name = "resultIndex", required = false) final Integer resultIndex,
            @RequestParam(name = "resultSize", required = false) final Integer resultSize,
            @RequestParam(name = "format", required = false) final String format, final HttpServletRequest request) {

        LOGGER.info(
                "retrieving Platform for 'platform-name': {} with depth: {}, resultIndex: {}, resultSize:{}, format: {} ...",
                lineOfBusinessName, depth, resultIndex, resultSize, format);

        final Optional<LineOfBusiness> optional = cacheServiceProvider.getLineOfBusiness(lineOfBusinessName);
        if (optional.isPresent()) {

            final Format value = Format.forValue(format);
            switch (value) {
                case RAW:
                    final LineOfBusiness platform = optional.get();
                    LOGGER.info("found LineOfBusiness {} in cache", platform);
                    return ResponseEntity.ok(platform);
                case COUNT:
                    final Map<String, Object> map = new HashMap<>();
                    map.put(LINE_OF_BUSINESS, 1);
                    return ResponseEntity.ok(new Results(map));
                default:
                    break;
            }
            LOGGER.error("invalid format type :{}", format);
        }
        LOGGER.error("Unable to find LineOfBusiness in cache using {}", lineOfBusinessName);
        return getRequestErrorResponseEntity(request, LINE_OF_BUSINESS);
    }

    @PutMapping(value = "/{line-of-business-name}" + BI_DIRECTIONAL_RELATIONSHIP_LIST_URL,
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putRelationShip(@PathVariable("line-of-business-name") final String lineOfBusinessName,
            @RequestBody final Relationship relationship, final HttpServletRequest request) {
        LOGGER.info("Will add {} relationship to : {} ...", relationship.getRelatedTo());

        final Optional<Relationship> optional =
                cacheServiceProvider.addRelationShip(lineOfBusinessName, relationship, request.getRequestURI());

        if (optional.isPresent()) {
            final Relationship resultantRelationship = optional.get();
            LOGGER.info("Relationship add, sending resultant relationship: {} in response ...", resultantRelationship);
            return ResponseEntity.accepted().body(resultantRelationship);
        }

        LOGGER.error("Couldn't add {} relationship for 'line-of-business-name': {} ...", relationship.getRelatedTo(),
                lineOfBusinessName);

        return getRequestErrorResponseEntity(request, LINE_OF_BUSINESS);

    }

}
