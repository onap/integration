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
package org.onap.aaisimulator.service.providers;

import org.onap.aai.domain.yang.v15.Pnf;
import org.onap.aaisimulator.utils.ShallowBeanCopy;
import org.onap.aaisimulator.cache.provider.AbstractCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

import static org.onap.aaisimulator.utils.CacheName.PNF_CACHE;

/**
 * @author Raj Gumma (raj.gumma@est.tech)
 */
@Service
public class PnfCacheServiceProviderImpl extends AbstractCacheServiceProvider implements PnfCacheServiceProvider {


    private static final Logger LOGGER = LoggerFactory.getLogger(PnfCacheServiceProvider.class);

    private final Cache cache;

    @Autowired
    public PnfCacheServiceProviderImpl(final CacheManager cacheManager) {
        super(cacheManager);
        cache = getCache(PNF_CACHE.getName());
    }

    @Override
    public void putPnf(final String pnfId, final Pnf pnf) {
        LOGGER.info("Adding pnf: {} with key: {} in cache ...", pnf, pnfId);
        cache.put(pnfId, pnf);
    }

    @Override
    public Optional<Pnf> getPnf(final String pnfId) {
        LOGGER.info("getting Pnf from cache using key: {}", pnfId);
        final Pnf value = cache.get(pnfId, Pnf.class);
        return Optional.ofNullable(value);
    }

    @Override
    public Optional<String> getPnfId(final String pnfName) {
        final Object nativeCache = cache.getNativeCache();
        if (nativeCache instanceof ConcurrentHashMap) {
            @SuppressWarnings("unchecked") final ConcurrentHashMap<Object, Object> concurrentHashMap =
                    (ConcurrentHashMap<Object, Object>) nativeCache;
            for (final Object key : concurrentHashMap.keySet()) {
                final Optional<Pnf> optional = getPnf(key.toString());
                if (optional.isPresent()) {
                    final String cachedPnfName = optional.get().getPnfName();
                    if (cachedPnfName != null && cachedPnfName.equals(cachedPnfName)) {
                        final String pnfId = optional.get().getPnfId();
                        LOGGER.info("Found matching pnf for name: {}, pnf-id: {}", cachedPnfName, pnfId);
                        return Optional.of(pnfId);
                    }
                }
            }
        }
        return Optional.empty();
    }

    @Override
    public boolean patchPnf(final String pnfId, final Pnf pnf) {
        final Optional<Pnf> optional = getPnf(pnfId);
        if (optional.isPresent()) {
            final Pnf cachedPnf = optional.get();
            try {
                ShallowBeanCopy.copy(pnf, cachedPnf);
                return true;
            } catch (final Exception exception) {
                LOGGER.error("Unable to update Pnf for pnfId: {}", pnfId, exception);
            }
        }
        LOGGER.error("Unable to find Pnf for pnfID : {}", pnfId);
        return false;
    }

    @Override
    public List<Pnf> getPnfs(String selfLink) {
        final Object nativeCache = cache.getNativeCache();
        if (nativeCache instanceof ConcurrentHashMap) {
            @SuppressWarnings("unchecked") final ConcurrentHashMap<Object, Object> concurrentHashMap =
                    (ConcurrentHashMap<Object, Object>) nativeCache;
            final List<Pnf> result = new ArrayList<>();

            concurrentHashMap.keySet().stream().forEach(key -> {
                final Optional<Pnf> optional = getPnf(key.toString());
                if (optional.isPresent()) {
                    final Pnf pnf = optional.get();
                    final String pnfSelfLink = pnf.getSelflink();
                    final String pnfId = pnf.getSelflink();

                    if (pnfSelfLink != null && pnfSelfLink.equals(selfLink)) {
                        LOGGER.info("Found matching pnf for selflink: {}, pnf-id: {}", pnfSelfLink,
                                pnfId);
                        result.add(pnf);
                    }
                }
            });
            return result;
        }
        LOGGER.error("No match found for selflink: {}", selfLink);
        return Collections.emptyList();
    }

    @Override
    public boolean deletePnf(String pnfId, String resourceVersion) {
        final Optional<Pnf> optional = getPnf(pnfId);
        if (optional.isPresent()) {
            final Pnf pnf = optional.get();
            if (pnf.getResourceVersion() != null && pnf.getResourceVersion().equals(resourceVersion)) {
                LOGGER.info("Will evict pnf from cache with pnfId: {}", pnf.getPnfId());
                cache.evict(pnfId);
                return true;
            }
        }
        LOGGER.error("Unable to find Pnf for pnfId: {} and resourceVersion: {} ...", pnfId, resourceVersion);
        return false;
    }

    @Override
    public void clearAll() {
        clearCache(cache.getName());
    }
}
