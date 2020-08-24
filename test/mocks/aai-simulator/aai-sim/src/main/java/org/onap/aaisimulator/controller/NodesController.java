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

import static org.onap.aaisimulator.utils.Constants.GENERIC_VNF;
import static org.onap.aaisimulator.utils.Constants.NODES_URL;
import static org.onap.aaisimulator.utils.Constants.RESOURCE_LINK;
import static org.onap.aaisimulator.utils.Constants.RESOURCE_TYPE;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.GenericVnfs;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aaisimulator.models.Format;
import org.onap.aaisimulator.models.NodeServiceInstance;
import org.onap.aaisimulator.models.Results;
import org.onap.aaisimulator.service.providers.NodesCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@Controller
@RequestMapping(path = NODES_URL)
public class NodesController {


    private static final Logger LOGGER = LoggerFactory.getLogger(NodesController.class);

    private final NodesCacheServiceProvider cacheServiceProvider;

    @Autowired
    public NodesController(final NodesCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @GetMapping(value = "/service-instances/service-instance/{service-instance-id}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getProject(@PathVariable(name = "service-instance-id") final String serviceInstanceId,
            @RequestParam(name = "format", required = false) final String format, final HttpServletRequest request) {
        LOGGER.info("retrieving service instance using 'service-instance-id': {} and format: {}...", serviceInstanceId,
                format);

        final Optional<NodeServiceInstance> optional = cacheServiceProvider.getNodeServiceInstance(serviceInstanceId);
        if (!optional.isPresent()) {
            LOGGER.error("Couldn't find {} in cache", serviceInstanceId);
            return getRequestErrorResponseEntity(request);
        }

        final Format value = Format.forValue(format);
        final NodeServiceInstance nodeServiceInstance = optional.get();
        switch (value) {
            case PATHED:
                LOGGER.info("found project {} in cache", nodeServiceInstance);
                final Map<String, Object> map = new LinkedHashMap<>();
                map.put(RESOURCE_TYPE, nodeServiceInstance.getResourceType());
                map.put(RESOURCE_LINK, nodeServiceInstance.getResourceLink());
                return ResponseEntity.ok(new Results(map));
            case RAW:
                final Optional<ServiceInstance> serviceInstance =
                        cacheServiceProvider.getServiceInstance(nodeServiceInstance);
                if (serviceInstance.isPresent()) {
                    return ResponseEntity.ok(serviceInstance.get());
                }
                LOGGER.error("Unable to find Service instance in cahce using {}", nodeServiceInstance);
                return getRequestErrorResponseEntity(request);
            default:
                break;
        }
        LOGGER.error("invalid format type :{}", format);
        return getRequestErrorResponseEntity(request);
    }

    @GetMapping(value = "/generic-vnfs", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getGenericVnfs(@RequestParam(name = "vnf-name") final String vnfName,
            final HttpServletRequest request) {
        LOGGER.info("will find GenericVnfs for name: {}", vnfName);
        final Optional<GenericVnfs> optional = cacheServiceProvider.getGenericVnfs(vnfName);
        if (optional.isPresent()) {
            LOGGER.info("found matching GenericVnfs for name: {}", vnfName);
            return ResponseEntity.ok(optional.get());
        }
        LOGGER.error("Unable to find GenericVnfs in cahce using {}", vnfName);
        return getRequestErrorResponseEntity(request, GENERIC_VNF);
    }
}
