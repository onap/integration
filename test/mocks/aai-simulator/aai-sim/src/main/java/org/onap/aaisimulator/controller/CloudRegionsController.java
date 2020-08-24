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
import static org.onap.aaisimulator.utils.Constants.CLOUD_REGION;
import static org.onap.aaisimulator.utils.Constants.CLOUD_REGIONS;
import static org.onap.aaisimulator.utils.Constants.ESR_SYSTEM_INFO_LIST;
import static org.onap.aaisimulator.utils.Constants.RELATIONSHIP_LIST_RELATIONSHIP_URL;
import static org.onap.aaisimulator.utils.Constants.VSERVER;
import static org.onap.aaisimulator.utils.HttpServiceUtils.getHeaders;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getResourceVersion;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.CloudRegion;
import org.onap.aai.domain.yang.EsrSystemInfo;
import org.onap.aai.domain.yang.EsrSystemInfoList;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.Tenant;
import org.onap.aai.domain.yang.Vserver;
import org.onap.aaisimulator.models.CloudRegionKey;
import org.onap.aaisimulator.service.providers.CloudRegionCacheServiceProvider;
import org.onap.aaisimulator.utils.HttpServiceUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.DeleteMapping;
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
@RequestMapping(path = CLOUD_REGIONS)
public class CloudRegionsController {
    private static final Logger LOGGER = LoggerFactory.getLogger(CloudRegionsController.class);

    private final CloudRegionCacheServiceProvider cacheServiceProvider;

    @Autowired
    public CloudRegionsController(final CloudRegionCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PutMapping(value = "{cloud-owner}/{cloud-region-id}",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putCloudRegion(@RequestBody final CloudRegion cloudRegion,
            @PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId, final HttpServletRequest request) {

        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);

        if (key.isValid()) {
            LOGGER.info("Will add CloudRegion to cache with key 'key': {} ....", key);
            if (cloudRegion.getResourceVersion() == null || cloudRegion.getResourceVersion().isEmpty()) {
                cloudRegion.setResourceVersion(getResourceVersion());
            }
            cacheServiceProvider.putCloudRegion(key, cloudRegion);
            return ResponseEntity.accepted().build();
        }

        LOGGER.error("Unable to add CloudRegion in cache because of invalid key {}", key);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);
    }

    @GetMapping(value = "{cloud-owner}/{cloud-region-id}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getCloudRegion(@PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @RequestParam(name = "depth", required = false) final Integer depth, final HttpServletRequest request) {
        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);
        LOGGER.info("Retrieving CloudRegion using key : {} with depth: {}...", key, depth);
        if (key.isValid()) {
            final Optional<CloudRegion> optional = cacheServiceProvider.getCloudRegion(key);
            if (optional.isPresent()) {
                final CloudRegion cloudRegion = optional.get();
                LOGGER.info("found CloudRegion {} in cache", cloudRegion);
                return ResponseEntity.ok(cloudRegion);
            }
        }
        LOGGER.error("Unable to find CloudRegion in cache using {}", key);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);
    }

    @PutMapping(value = "{cloud-owner}/{cloud-region-id}" + BI_DIRECTIONAL_RELATIONSHIP_LIST_URL,
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putRelationShip(@PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId, @RequestBody final Relationship relationship,
            final HttpServletRequest request) {
        LOGGER.info("Will add {} relationship to : {} ...", relationship.getRelatedTo());

        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);

        final Optional<Relationship> optional =
                cacheServiceProvider.addRelationShip(key, relationship, request.getRequestURI());

        if (optional.isPresent()) {
            final Relationship resultantRelationship = optional.get();
            LOGGER.info("Relationship add, sending resultant relationship: {} in response ...", resultantRelationship);
            return ResponseEntity.accepted().body(resultantRelationship);
        }

        LOGGER.error("Couldn't add {} relationship for 'key': {} ...", relationship.getRelatedTo(), key);
        return getRequestErrorResponseEntity(request, VSERVER);

    }

    @PutMapping(value = "{cloud-owner}/{cloud-region-id}/tenants/tenant/{tenant-id}",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putTenant(@RequestBody final Tenant tenant,
            @PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @PathVariable("tenant-id") final String tenantId, final HttpServletRequest request) {

        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);

        if (key.isValid()) {
            LOGGER.info("Will add Tenant to cache with key 'key': {} ....", key);
            if (tenant.getResourceVersion() == null || tenant.getResourceVersion().isEmpty()) {
                tenant.setResourceVersion(getResourceVersion());
            }
            if (cacheServiceProvider.putTenant(key, tenantId, tenant)) {
                return ResponseEntity.accepted().build();
            }
        }

        LOGGER.error("Unable to add Tenant in cache using key {}", key);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);
    }

    @GetMapping(value = "{cloud-owner}/{cloud-region-id}/tenants/tenant/{tenant-id}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getTenant(@PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @PathVariable("tenant-id") final String tenantId, final HttpServletRequest request) {
        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);
        LOGGER.info("Retrieving Tenant using key : {} and tenant-id:{} ...", key, tenantId);
        if (key.isValid()) {
            final Optional<Tenant> optional = cacheServiceProvider.getTenant(key, tenantId);
            if (optional.isPresent()) {
                final Tenant tenant = optional.get();
                LOGGER.info("found Tenant {} in cache", tenant);
                return ResponseEntity.ok(tenant);
            }
        }
        LOGGER.error("Unable to find Tenant in cache key : {} and tenant-id:{} ...", key, tenantId);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);
    }

    @PutMapping(
            value = "{cloud-owner}/{cloud-region-id}/tenants/tenant/{tenant-id}" + RELATIONSHIP_LIST_RELATIONSHIP_URL,
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putRelationShip(@RequestBody final Relationship relationship,
            @PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @PathVariable("tenant-id") final String tenantId, final HttpServletRequest request) {

        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);
        LOGGER.info("Will put RelationShip for key : {} and tenant-id:{} ...", key, tenantId);

        if (relationship.getRelatedLink() != null) {
            final String targetBaseUrl = HttpServiceUtils.getBaseUrl(request).toString();
            final HttpHeaders incomingHeader = getHeaders(request);
            final boolean result = cacheServiceProvider.addRelationShip(incomingHeader, targetBaseUrl,
                    request.getRequestURI(), key, tenantId, relationship);
            if (result) {
                LOGGER.info("added created bi directional relationship with {}", relationship.getRelatedLink());
                return ResponseEntity.accepted().build();
            }

        }
        LOGGER.error("Unable to add relationship for related link: {}", relationship.getRelatedLink());
        return getRequestErrorResponseEntity(request, CLOUD_REGION);
    }

    @PutMapping(value = "{cloud-owner}/{cloud-region-id}/esr-system-info-list/esr-system-info/{esr-system-info-id}",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putEsrSystemInfo(@RequestBody final EsrSystemInfo esrSystemInfo,
            @PathVariable("esr-system-info-id") final String esrSystemInfoId,
            @PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId, final HttpServletRequest request) {

        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);

        LOGGER.info("Will put esrSystemInfo for 'key': {} ...", key);

        if (esrSystemInfo.getResourceVersion() == null || esrSystemInfo.getResourceVersion().isEmpty()) {
            esrSystemInfo.setResourceVersion(getResourceVersion());

        }

        if (cacheServiceProvider.putEsrSystemInfo(key, esrSystemInfoId, esrSystemInfo)) {
            LOGGER.info("Successfully added EsrSystemInfo key : {}  ...", key, esrSystemInfo);
            return ResponseEntity.accepted().build();
        }
        LOGGER.error("Unable to add EsrSystemInfo in cache for key : {} ...", key);

        return getRequestErrorResponseEntity(request, ESR_SYSTEM_INFO_LIST);
    }

    @GetMapping(value = "{cloud-owner}/{cloud-region-id}/esr-system-info-list",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getEsrSystemInfoList(@PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId, final HttpServletRequest request) {
        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);
        LOGGER.info("Retrieving EsrSystemInfoList using key : {} ...", key);
        if (key.isValid()) {
            final Optional<EsrSystemInfoList> optional = cacheServiceProvider.getEsrSystemInfoList(key);
            if (optional.isPresent()) {
                final EsrSystemInfoList esrSystemInfoList = optional.get();
                LOGGER.info("found EsrSystemInfoList {} in cache", esrSystemInfoList);
                return ResponseEntity.ok(esrSystemInfoList);
            }
        }
        LOGGER.error("Unable to find EsrSystemInfoList in cache using key : {} ...", key);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);
    }

    @PutMapping(value = "{cloud-owner}/{cloud-region-id}/tenants/tenant/{tenant-id}/vservers/vserver/{vserver-id}",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putVserver(@RequestBody final Vserver vServer,
            @PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @PathVariable("tenant-id") final String tenantId, @PathVariable("vserver-id") final String vServerId,
            final HttpServletRequest request) {

        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);
        if (vServer.getResourceVersion() == null || vServer.getResourceVersion().isEmpty()) {
            vServer.setResourceVersion(getResourceVersion());
        }
        LOGGER.info("Will put Vserver in cache using using key: {}, tenantId: {}, vServerId: {} ...", key, tenantId,
                vServerId);

        if (cacheServiceProvider.putVserver(key, tenantId, vServerId, vServer)) {

            if (vServer.getRelationshipList() != null) {
                for (final Relationship relationship : vServer.getRelationshipList().getRelationship()) {
                    if (relationship.getRelatedLink() != null) {
                        final String requestUri = request.getRequestURI();
                        final String targetBaseUrl =
                                HttpServiceUtils.getBaseUrl(request.getRequestURL(), requestUri).toString();
                        final HttpHeaders incomingHeader = getHeaders(request);
                        final boolean result = cacheServiceProvider.addVServerRelationShip(incomingHeader,
                                targetBaseUrl, requestUri, key, tenantId, vServerId, relationship);
                        if (!result) {
                            LOGGER.error(
                                    "Unable to add Vserver relationship in cache using key: {}, tenantId: {}, vServerId: {}",
                                    key, tenantId, vServerId);
                            return getRequestErrorResponseEntity(request, CLOUD_REGION);
                        }
                        LOGGER.info("Successfully added relationship with {}", relationship.getRelatedLink());
                    }
                }
            }

            LOGGER.info("Successfully added Vserver for key: {}, tenantId: {}, vServerId: {} ...", key, tenantId,
                    vServerId);
            return ResponseEntity.accepted().build();
        }
        LOGGER.error("Unable to add Vserver in cache using key: {}, tenantId: {}, vServerId: {}", key, tenantId,
                vServerId);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);
    }

    @GetMapping(value = "{cloud-owner}/{cloud-region-id}/tenants/tenant/{tenant-id}/vservers/vserver/{vserver-id}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getVserver(@PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @PathVariable("tenant-id") final String tenantId, @PathVariable("vserver-id") final String vServerId,
            final HttpServletRequest request) {

        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);
        LOGGER.info("Retrieving Vserver using key: {}, tenant-id: {}  and vserver-id: {}...", key, tenantId, vServerId);
        final Optional<Vserver> optional = cacheServiceProvider.getVserver(key, tenantId, vServerId);
        if (optional.isPresent()) {
            final Vserver vServer = optional.get();
            LOGGER.info("found Vserver {} in cache", vServer);
            return ResponseEntity.ok(vServer);
        }
        LOGGER.error("Unable to find Vserver in cache using key: {}, tenant-id: {}  and vserver-id: {}...", key,
                tenantId, vServerId);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);
    }


    @DeleteMapping(value = "{cloud-owner}/{cloud-region-id}/tenants/tenant/{tenant-id}/vservers/vserver/{vserver-id}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> deleteVserver(@PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @PathVariable("tenant-id") final String tenantId, @PathVariable("vserver-id") final String vServerId,
            @RequestParam(name = "resource-version") final String resourceVersion, final HttpServletRequest request) {

        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);
        LOGGER.info("Will delete Vserver using key: {}, tenant-id: {}, vserver-id: {} and resource-version: {}...", key,
                tenantId, vServerId, resourceVersion);


        if (cacheServiceProvider.deleteVserver(key, tenantId, vServerId, resourceVersion)) {
            LOGGER.info(
                    "Successfully delete Vserver from cache for key: {}, tenant-id: {}, vserver-id: {} and resource-version: {}",
                    key, tenantId, vServerId, resourceVersion);
            return ResponseEntity.noContent().build();
        }

        LOGGER.error(
                "Unable to delete Vserver from cache using key: {}, tenant-id: {}, vserver-id: {} and resource-version: {} ...",
                key, tenantId, vServerId, resourceVersion);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);
    }

    @PutMapping(
            value = "{cloud-owner}/{cloud-region-id}/tenants/tenant/{tenant-id}/vservers/vserver/{vserver-id}"
                    + RELATIONSHIP_LIST_RELATIONSHIP_URL,
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putVserverRelationShip(@PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @PathVariable("tenant-id") final String tenantId, @PathVariable("vserver-id") final String vServerId,
            @RequestBody final Relationship relationship, final HttpServletRequest request) {
        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);
        LOGGER.info("Will add {} relationship to : {} ...", relationship.getRelatedTo());

        if (relationship.getRelatedLink() != null) {
            final String targetBaseUrl = HttpServiceUtils.getBaseUrl(request).toString();
            final HttpHeaders incomingHeader = getHeaders(request);
            final boolean result = cacheServiceProvider.addVServerRelationShip(incomingHeader, targetBaseUrl,
                    request.getRequestURI(), key, tenantId, vServerId, relationship);
            if (result) {
                LOGGER.info("added created bi directional relationship with {}", relationship.getRelatedLink());
                return ResponseEntity.accepted().build();
            }
        }
        LOGGER.error("Couldn't add {} relationship for 'key': {} ...", relationship.getRelatedTo(), key);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);

    }

    @PutMapping(
            value = "{cloud-owner}/{cloud-region-id}/tenants/tenant/{tenant-id}/vservers/vserver/{vserver-id}"
                    + BI_DIRECTIONAL_RELATIONSHIP_LIST_URL,
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putBiDirectionalVServerRelationShip(@PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @PathVariable("tenant-id") final String tenantId, @PathVariable("vserver-id") final String vServerId,
            @RequestBody final Relationship relationship, final HttpServletRequest request) {
        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);
        LOGGER.info("Will add {} relationship to : {} ...", relationship.getRelatedTo());

        final Optional<Relationship> optional = cacheServiceProvider.addvServerRelationShip(key, tenantId, vServerId,
                relationship, request.getRequestURI());

        if (optional.isPresent()) {
            final Relationship resultantRelationship = optional.get();
            LOGGER.info("Relationship add, sending resultant relationship: {} in response ...", resultantRelationship);
            return ResponseEntity.accepted().body(resultantRelationship);
        }
        LOGGER.error("Couldn't add {} relationship for 'key': {} ...", relationship.getRelatedTo(), key);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);

    }
}
