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

import static org.onap.aaisimulator.utils.CacheName.NODES_CACHE;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import org.onap.aai.domain.yang.GenericVnf;
import org.onap.aai.domain.yang.GenericVnfs;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aaisimulator.models.NodeServiceInstance;
import org.onap.aaisimulator.cache.provider.AbstractCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@Service
public class NodesCacheServiceProviderImpl extends AbstractCacheServiceProvider implements NodesCacheServiceProvider {
    private static final Logger LOGGER = LoggerFactory.getLogger(NodesCacheServiceProviderImpl.class);
    private final GenericVnfCacheServiceProvider cacheServiceProvider;
    private final CustomerCacheServiceProvider customerCacheServiceProvider;


    @Autowired
    public NodesCacheServiceProviderImpl(final CacheManager cacheManager,
            final GenericVnfCacheServiceProvider cacheServiceProvider,
            final CustomerCacheServiceProvider customerCacheServiceProvider) {
        super(cacheManager);
        this.cacheServiceProvider = cacheServiceProvider;
        this.customerCacheServiceProvider = customerCacheServiceProvider;
    }

    @Override
    public void putNodeServiceInstance(final String serviceInstanceId, final NodeServiceInstance nodeServiceInstance) {
        final Cache cache = getCache(NODES_CACHE.getName());
        LOGGER.info("Adding {} to cache with key: {}...", nodeServiceInstance, serviceInstanceId);
        cache.put(serviceInstanceId, nodeServiceInstance);
    }

    @Override
    public Optional<NodeServiceInstance> getNodeServiceInstance(final String serviceInstanceId) {
        final Cache cache = getCache(NODES_CACHE.getName());
        final NodeServiceInstance value = cache.get(serviceInstanceId, NodeServiceInstance.class);
        if (value != null) {
            return Optional.of(value);
        }
        LOGGER.error("Unable to find node service instance in cache using key:{} ", serviceInstanceId);
        return Optional.empty();
    }

    @Override
    public Optional<GenericVnfs> getGenericVnfs(final String vnfName) {
        final Optional<String> genericVnfId = cacheServiceProvider.getGenericVnfId(vnfName);
        if (genericVnfId.isPresent()) {
            final Optional<GenericVnf> genericVnf = cacheServiceProvider.getGenericVnf(genericVnfId.get());
            if (genericVnf.isPresent()) {
                final GenericVnfs genericVnfs = new GenericVnfs();
                genericVnfs.getGenericVnf().add(genericVnf.get());
                return Optional.of(genericVnfs);
            }
        }
        LOGGER.error("Unable to find GenericVnf for name: {}", vnfName);
        return Optional.empty();
    }

    @Override
    public Optional<ServiceInstance> getServiceInstance(final NodeServiceInstance nodeServiceInstance) {
        return customerCacheServiceProvider.getServiceInstance(nodeServiceInstance.getGlobalCustomerId(),
                nodeServiceInstance.getServiceType(), nodeServiceInstance.getServiceInstanceId());
    }

    @Override
    public void clearAll() {
        final Cache cache = getCache(NODES_CACHE.getName());
        final ConcurrentHashMap<?, ?> nativeCache = (ConcurrentHashMap<?, ?>) cache.getNativeCache();
        LOGGER.info("Clear all entries from cahce: {}", cache.getName());
        nativeCache.clear();
    }

}
