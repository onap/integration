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

import static org.onap.aaisimulator.utils.Constants.ESR_SYSTEM_INFO;
import static org.onap.aaisimulator.utils.Constants.ESR_SYSTEM_INFO_LIST;
import static org.onap.aaisimulator.utils.Constants.ESR_VNFM;
import static org.onap.aaisimulator.utils.Constants.EXTERNAL_SYSTEM_ESR_VNFM_LIST_URL;
import static org.onap.aaisimulator.utils.Constants.RELATIONSHIP_LIST_RELATIONSHIP_URL;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getHeaders;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getResourceVersion;
import java.util.List;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.EsrSystemInfo;
import org.onap.aai.domain.yang.EsrSystemInfoList;
import org.onap.aai.domain.yang.EsrVnfm;
import org.onap.aai.domain.yang.EsrVnfmList;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aaisimulator.service.providers.ExternalSystemCacheServiceProvider;
import org.onap.aaisimulator.utils.HttpServiceUtils;
import org.onap.aaisimulator.utils.RequestErrorResponseUtils;
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
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Controller
@RequestMapping(path = EXTERNAL_SYSTEM_ESR_VNFM_LIST_URL)
public class ExternalSystemEsrController {
    private static final Logger LOGGER = LoggerFactory.getLogger(ExternalSystemEsrController.class);

    private final ExternalSystemCacheServiceProvider cacheServiceProvider;

    @Autowired
    public ExternalSystemEsrController(final ExternalSystemCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PutMapping(value = "/esr-vnfm/{vnfm-id}", consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putEsrVnfm(@RequestBody final EsrVnfm esrVnfm,
            @PathVariable("vnfm-id") final String vnfmId, final HttpServletRequest request) {
        LOGGER.info("Will put esr-vnfm to cache for 'vnfm id': {} ...", esrVnfm.getVnfmId());

        if (esrVnfm.getResourceVersion() == null || esrVnfm.getResourceVersion().isEmpty()) {
            esrVnfm.setResourceVersion(getResourceVersion());

        }
        cacheServiceProvider.putEsrVnfm(vnfmId, esrVnfm);
        return ResponseEntity.accepted().build();
    }

    @GetMapping(value = "/esr-vnfm/{vnfm-id}", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getEsrVnfm(@PathVariable("vnfm-id") final String vnfmId,
            @RequestParam(name = "depth", required = false) final Integer depth, final HttpServletRequest request) {
        LOGGER.info("Will retrieve ESR VNFM for 'vnfm id': {} with depth: {}...", vnfmId, depth);

        final Optional<EsrVnfm> optional = cacheServiceProvider.getEsrVnfm(vnfmId);
        if (optional.isPresent()) {
            final EsrVnfm esrVnfm = optional.get();
            LOGGER.info("found esrVnfm {} in cache", esrVnfm);
            return ResponseEntity.ok(esrVnfm);
        }

        LOGGER.error("Couldn't Esr Vnfm for 'vnfm id': {} with depth: {}...", vnfmId, depth);
        return getRequestErrorResponseEntity(request, ESR_VNFM);
    }

    @GetMapping(produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getEsrVnfmList(final HttpServletRequest request) {
        LOGGER.info("Will retrieve a list of all ESR VNFMs");

        final List<EsrVnfm> esrVnfms = cacheServiceProvider.getAllEsrVnfm();
        LOGGER.info("found {} Esr Vnfms in cache", esrVnfms.size());

        final EsrVnfmList esrVnfmList = new EsrVnfmList();
        esrVnfmList.getEsrVnfm().addAll(esrVnfms);

        return ResponseEntity.ok(esrVnfmList);
    }

    @PutMapping(value = "/esr-vnfm/{vnfm-id}/esr-system-info-list/esr-system-info/{esr-system-info-id}",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putEsrSystemInfo(@RequestBody final EsrSystemInfo esrSystemInfo,
            @PathVariable("vnfm-id") final String vnfmId,
            @PathVariable("esr-system-info-id") final String esrSystemInfoId, final HttpServletRequest request) {
        LOGGER.info("Will put esrSystemInfo for 'vnfm id': {} and 'esr-system-info-id': {} ...", vnfmId, esrSystemInfo);

        if (esrSystemInfo.getResourceVersion() == null || esrSystemInfo.getResourceVersion().isEmpty()) {
            esrSystemInfo.setResourceVersion(getResourceVersion());

        }

        if (cacheServiceProvider.putEsrSystemInfo(vnfmId, esrSystemInfoId, esrSystemInfo)) {
            LOGGER.info("Successfully added EsrSystemInfo for 'vnfm id': {} and 'esr-system-info-id': {} ...", vnfmId,
                    esrSystemInfo);
            return ResponseEntity.accepted().build();
        }
        LOGGER.error("Unable to add esrSystemInfo for 'vnfm id': {} and 'esr-system-info-id': {} ...", vnfmId,
                esrSystemInfo);
        return getRequestErrorResponseEntity(request, ESR_SYSTEM_INFO_LIST);
    }

    @GetMapping(value = "/esr-vnfm/{vnfm-id}/esr-system-info-list",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getEsrSystemInfoList(@PathVariable("vnfm-id") final String vnfmId,
            final HttpServletRequest request) {
        LOGGER.info("Will retrieve esrSystemInfoList for 'vnfm id': {} ...", vnfmId);

        final Optional<EsrSystemInfoList> optional = cacheServiceProvider.getEsrSystemInfoList(vnfmId);
        if (optional.isPresent()) {
            final EsrSystemInfoList esrSystemInfoList = optional.get();
            LOGGER.info("found esrSystemInfoList {} in cache", esrSystemInfoList);
            return ResponseEntity.ok(esrSystemInfoList);
        }

        LOGGER.error("Couldn't find esrSystemInfoList for 'vnfm id': {} ...", vnfmId);
        return getRequestErrorResponseEntity(request, ESR_SYSTEM_INFO);
    }

    @PutMapping(value = "/esr-vnfm/{vnfm-id}" + RELATIONSHIP_LIST_RELATIONSHIP_URL,
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putEsrVnfmRelationShip(@RequestBody final Relationship relationship,
            @PathVariable("vnfm-id") final String vnfmId, final HttpServletRequest request) {
        LOGGER.info("Will put RelationShip for 'vnfm-id': {} ...", vnfmId);

        if (relationship.getRelatedLink() != null) {
            final String targetBaseUrl = HttpServiceUtils.getBaseUrl(request).toString();
            final HttpHeaders incomingHeader = getHeaders(request);
            final boolean result = cacheServiceProvider.addRelationShip(incomingHeader, targetBaseUrl,
                    request.getRequestURI(), vnfmId, relationship);
            if (result) {
                LOGGER.info("added created bi directional relationship with {}", relationship.getRelatedLink());
                return ResponseEntity.accepted().build();
            }
        }
        LOGGER.error("Unable to add relationship for related link: {}", relationship.getRelatedLink());
        return RequestErrorResponseUtils.getRequestErrorResponseEntity(request, ESR_VNFM);
    }

}
