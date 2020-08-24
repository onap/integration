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
package org.onap.aaisimulator.cache.provider;

import java.util.concurrent.ConcurrentHashMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;

/**
 * @author Waqas Ikram (waqas.ikram@ericsson.com)
 */
public abstract class AbstractCacheServiceProvider {

    private final Logger LOGGER = LoggerFactory.getLogger(this.getClass());

    private final CacheManager cacheManager;

    public AbstractCacheServiceProvider(final CacheManager cacheManager) {
        this.cacheManager = cacheManager;
    }

    protected void clearCache(final String name) {
        final Cache cache = cacheManager.getCache(name);
        if (cache != null) {
            final ConcurrentHashMap<?, ?> nativeCache = (ConcurrentHashMap<?, ?>) cache.getNativeCache();
            LOGGER.info("Clear all entries from cahce: {}", cache.getName());
            nativeCache.clear();
        }
    }

    protected Cache getCache(final String name) {
        return cacheManager.getCache(name);
    }

}
