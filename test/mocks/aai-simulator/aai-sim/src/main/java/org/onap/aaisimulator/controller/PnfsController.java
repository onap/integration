/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2020 Nordix Foundation.
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


import org.onap.aai.domain.yang.v15.Pnf;
import org.onap.aai.domain.yang.v15.Pnfs;
import org.onap.aaisimulator.service.providers.PnfCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
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

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import java.util.List;
import java.util.Optional;

import static org.onap.aaisimulator.utils.Constants.APPLICATION_MERGE_PATCH_JSON;
import static org.onap.aaisimulator.utils.Constants.PNF;
import static org.onap.aaisimulator.utils.Constants.PNFS_URL;
import static org.onap.aaisimulator.utils.Constants.X_HTTP_METHOD_OVERRIDE;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getResourceVersion;

/**
 * @author Raj Gumma (raj.gumma@est.tech)
 */
@Controller
@RequestMapping(path = PNFS_URL)
public class PnfsController {

    private static final Logger LOGGER = LoggerFactory.getLogger(PnfsController.class);

    private final PnfCacheServiceProvider cacheServiceProvider;


    @Autowired
    public PnfsController(final PnfCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PutMapping(value = "/pnf/{pnf-id}", consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putPnf(@RequestBody final Pnf pnf,
                                    @PathVariable("pnf-id") final String pnfId, final HttpServletRequest request) {
        LOGGER.info("Will add Pnf to cache with 'pnf-id': {} ...", pnfId);

        if (pnf.getResourceVersion() == null || pnf.getResourceVersion().isEmpty()) {
            pnf.setResourceVersion(getResourceVersion());
        }
        cacheServiceProvider.putPnf(pnfId, pnf);
        return ResponseEntity.accepted().build();
    }

    @GetMapping(value = "/pnf/{pnf-id}", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getPnf(@PathVariable("pnf-id") final String pnfId, final HttpServletRequest request) {
        LOGGER.info("Will get Pnf for 'pnf-id': {} ", pnfId);

        final Optional<Pnf> optional = cacheServiceProvider.getPnf(pnfId);

        if (optional.isPresent()) {
            final Pnf pnf = optional.get();
            LOGGER.info("found Pnf {} in cache", pnf);
            return ResponseEntity.ok(pnf);
        }

        LOGGER.error("Unable to find Pnf in cache for 'pnf-id': {}", pnfId);
        return getRequestErrorResponseEntity(request, "pnf");

    }

    @PostMapping(value = "/pnf/{pnf-id}",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML, APPLICATION_MERGE_PATCH_JSON},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> patchPnf(@RequestBody final Pnf pnf,
                                      @PathVariable("pnf-id") final String pnfId,
                                      @RequestHeader(value = X_HTTP_METHOD_OVERRIDE, required = false) final String xHttpHeaderOverride,
                                      final HttpServletRequest request) {

        LOGGER.info("Will post Pnf to cache with 'pnf-id': {} and '{}': {} ...", pnfId, X_HTTP_METHOD_OVERRIDE,
                xHttpHeaderOverride);

        if (HttpMethod.PATCH.toString().equalsIgnoreCase(xHttpHeaderOverride)) {
            if (cacheServiceProvider.patchPnf(pnfId, pnf)) {
                return ResponseEntity.accepted().build();
            }
            LOGGER.error("Unable to apply patch to Pnf using 'pnf-id': {} ... ", pnfId);
            return getRequestErrorResponseEntity(request, PNF);
        }
        LOGGER.error("{} not supported ... ", xHttpHeaderOverride);

        return getRequestErrorResponseEntity(request, PNF);
    }

    @GetMapping(produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getPnfs(@RequestParam(name = "selflink") final String selflink,
                                     final HttpServletRequest request) {
        LOGGER.info("will retrieve Pnfs using selflink: {}", selflink);

        final List<Pnf> pnfList = cacheServiceProvider.getPnfs(selflink);

        if (pnfList.isEmpty()) {
            LOGGER.error("No matching pnfs found using selflink: {}", selflink);
            return getRequestErrorResponseEntity(request, PNF);
        }

        LOGGER.info("found {} Pnfs in cache", pnfList.size());
        final Pnfs pnfs = new Pnfs();
        pnfs.getPnf().addAll(pnfList);
        return ResponseEntity.ok(pnfs);
    }

    @DeleteMapping(value = "/pnf/{pnf-id}", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> deletePnf(@PathVariable("pnf-id") final String pnfId,
                                       @RequestParam(name = "resource-version") final String resourceVersion, final HttpServletRequest request) {
        LOGGER.info("Will delete Pnf for 'pnf-id': {} and 'resource-version': {}", pnfId, resourceVersion);

        if (cacheServiceProvider.deletePnf(pnfId, resourceVersion)) {
            LOGGER.info("Successfully delete Pnf from cache for 'pnf-id': {} and 'resource-version': {}", pnfId,
                    resourceVersion);
            return ResponseEntity.noContent().build();
        }

        LOGGER.error("Unable to delete Pnf for 'pnf-id': {} and 'resource-version': {} ...", pnfId,
                resourceVersion);
        return getRequestErrorResponseEntity(request, PNF);

    }

}
