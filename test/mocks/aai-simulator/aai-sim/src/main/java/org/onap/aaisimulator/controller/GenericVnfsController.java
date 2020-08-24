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

import static org.onap.aaisimulator.utils.Constants.APPLICATION_MERGE_PATCH_JSON;
import static org.onap.aaisimulator.utils.Constants.BI_DIRECTIONAL_RELATIONSHIP_LIST_URL;
import static org.onap.aaisimulator.utils.Constants.GENERIC_VNF;
import static org.onap.aaisimulator.utils.Constants.GENERIC_VNFS_URL;
import static org.onap.aaisimulator.utils.Constants.RELATIONSHIP_LIST_RELATIONSHIP_URL;
import static org.onap.aaisimulator.utils.Constants.X_HTTP_METHOD_OVERRIDE;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getHeaders;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getResourceVersion;
import java.util.List;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.GenericVnf;
import org.onap.aai.domain.yang.GenericVnfs;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aaisimulator.service.providers.GenericVnfCacheServiceProvider;
import org.onap.aaisimulator.utils.HttpServiceUtils;
import org.onap.aaisimulator.utils.RequestErrorResponseUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Controller
@RequestMapping(path = GENERIC_VNFS_URL)
public class GenericVnfsController {

    private static final Logger LOGGER = LoggerFactory.getLogger(GenericVnfsController.class);

    private final GenericVnfCacheServiceProvider cacheServiceProvider;


    @Autowired
    public GenericVnfsController(final GenericVnfCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PutMapping(value = "/generic-vnf/{vnf-id}", consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putGenericVnf(@RequestBody final GenericVnf genericVnf,
            @PathVariable("vnf-id") final String vnfId, final HttpServletRequest request) {
        LOGGER.info("Will add GenericVnf to cache with 'vnf-id': {} ...", vnfId);

        if (genericVnf.getResourceVersion() == null || genericVnf.getResourceVersion().isEmpty()) {
            genericVnf.setResourceVersion(getResourceVersion());

        }
        cacheServiceProvider.putGenericVnf(vnfId, genericVnf);
        return ResponseEntity.accepted().build();

    }

    @GetMapping(value = "/generic-vnf/{vnf-id}", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getGenericVnf(@PathVariable("vnf-id") final String vnfId,
            @RequestParam(name = "depth", required = false) final Integer depth,
            @RequestParam(name = "resultIndex", required = false) final Integer resultIndex,
            @RequestParam(name = "resultSize", required = false) final Integer resultSize,
            @RequestParam(name = "format", required = false) final String format, final HttpServletRequest request) {
        LOGGER.info(
                "Will get GenericVnf for 'vnf-id': {} with depth: {}, resultIndex: {}, resultSize:{}, format: {} ...",
                vnfId, depth, resultIndex, resultSize, format);

        final Optional<GenericVnf> optional = cacheServiceProvider.getGenericVnf(vnfId);

        if (optional.isPresent()) {
            final GenericVnf genericVnf = optional.get();
            LOGGER.info("found GenericVnf {} in cache", genericVnf);
            return ResponseEntity.ok(genericVnf);
        }

        LOGGER.error(
                "Unable to find GenericVnf in cache for 'vnf-id': {} with depth: {}, resultIndex: {}, resultSize:{}, format:{} ...",
                vnfId, depth, resultIndex, resultSize, format);
        return getRequestErrorResponseEntity(request, GENERIC_VNF);

    }

    @PutMapping(value = "/generic-vnf/{vnf-id}" + RELATIONSHIP_LIST_RELATIONSHIP_URL,
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putGenericVnfRelationShip(@RequestBody final Relationship relationship,
            @PathVariable("vnf-id") final String vnfId, final HttpServletRequest request) {
        LOGGER.info("Will put RelationShip for 'vnf-id': {} ...", vnfId);

        if (relationship.getRelatedLink() != null) {
            final String targetBaseUrl = HttpServiceUtils.getBaseUrl(request).toString();
            final HttpHeaders incomingHeader = getHeaders(request);
            final boolean result = cacheServiceProvider.addRelationShip(incomingHeader, targetBaseUrl,
                    request.getRequestURI(), vnfId, relationship);
            if (result) {
                LOGGER.info("added created bi directional relationship with {}", relationship.getRelatedLink());
                return ResponseEntity.accepted().build();
            }
        }
        LOGGER.error("Unable to add relationship for related link: {}", relationship.getRelatedLink());
        return RequestErrorResponseUtils.getRequestErrorResponseEntity(request, GENERIC_VNF);
    }

    @PutMapping(value = "/generic-vnf/{vnf-id}" + BI_DIRECTIONAL_RELATIONSHIP_LIST_URL,
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putBiDirectionalRelationShip(@RequestBody final Relationship relationship,
            @PathVariable("vnf-id") final String vnfId, final HttpServletRequest request) {
        LOGGER.info("Will put RelationShip for 'vnf-id': {} ...", vnfId);

        final Optional<Relationship> optional =
                cacheServiceProvider.addRelationShip(vnfId, relationship, request.getRequestURI());

        if (optional.isPresent()) {
            final Relationship resultantRelationship = optional.get();
            LOGGER.info("Relationship add, sending resultant relationship: {} in response ...", resultantRelationship);
            return ResponseEntity.accepted().body(resultantRelationship);
        }

        LOGGER.error("Unable to add relationship for related link: {}", relationship.getRelatedLink());
        return RequestErrorResponseUtils.getRequestErrorResponseEntity(request, GENERIC_VNF);
    }

    @PostMapping(value = "/generic-vnf/{vnf-id}",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML, APPLICATION_MERGE_PATCH_JSON},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> patchGenericVnf(@RequestBody final GenericVnf genericVnf,
            @PathVariable("vnf-id") final String vnfId,
            @RequestHeader(value = X_HTTP_METHOD_OVERRIDE, required = false) final String xHttpHeaderOverride,
            final HttpServletRequest request) {

        LOGGER.info("Will post GenericVnf to cache with 'vnf-id': {} and '{}': {} ...", vnfId, X_HTTP_METHOD_OVERRIDE,
                xHttpHeaderOverride);

        if (HttpMethod.PATCH.toString().equalsIgnoreCase(xHttpHeaderOverride)) {
            if (cacheServiceProvider.patchGenericVnf(vnfId, genericVnf)) {
                return ResponseEntity.accepted().build();
            }
            LOGGER.error("Unable to apply patch to GenericVnf using 'vnf-id': {} ... ", vnfId);
            return getRequestErrorResponseEntity(request, GENERIC_VNF);
        }
        LOGGER.error("{} not supported ... ", xHttpHeaderOverride);

        return getRequestErrorResponseEntity(request, GENERIC_VNF);
    }

    @GetMapping(produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getGenericVnfs(@RequestParam(name = "selflink") final String selflink,
            final HttpServletRequest request) {
        LOGGER.info("will retrieve GenericVnfs using selflink: {}", selflink);

        final List<GenericVnf> genericVnfList = cacheServiceProvider.getGenericVnfs(selflink);

        if (genericVnfList.isEmpty()) {
            LOGGER.error("No matching generic vnfs found using selflink: {}", selflink);
            return getRequestErrorResponseEntity(request, GENERIC_VNF);
        }

        LOGGER.info("found {} GenericVnfs in cache", genericVnfList.size());
        final GenericVnfs genericVnfs = new GenericVnfs();
        genericVnfs.getGenericVnf().addAll(genericVnfList);
        return ResponseEntity.ok(genericVnfs);
    }

    @DeleteMapping(value = "/generic-vnf/{vnf-id}", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> deleteGenericVnf(@PathVariable("vnf-id") final String vnfId,
            @RequestParam(name = "resource-version") final String resourceVersion, final HttpServletRequest request) {
        LOGGER.info("Will delete GenericVnf for 'vnf-id': {} and 'resource-version': {}", vnfId, resourceVersion);

        if (cacheServiceProvider.deleteGenericVnf(vnfId, resourceVersion)) {
            LOGGER.info("Successfully delete GenericVnf from cache for 'vnf-id': {} and 'resource-version': {}", vnfId,
                    resourceVersion);
            return ResponseEntity.noContent().build();
        }

        LOGGER.error("Unable to delete GenericVnf for 'vnf-id': {} and 'resource-version': {} ...", vnfId,
                resourceVersion);
        return getRequestErrorResponseEntity(request, GENERIC_VNF);

    }

}
