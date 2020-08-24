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
package org.onap.aaisimulator.models;

import java.io.Serializable;
import org.springframework.util.ObjectUtils;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class CloudRegionKey implements Serializable {

    private static final long serialVersionUID = 6175094050996035737L;

    private final String cloudOwner;

    private final String cloudRegionId;

    public CloudRegionKey(final String cloudOwner, final String cloudRegionId) {
        this.cloudOwner = cloudOwner;
        this.cloudRegionId = cloudRegionId;
    }

    /**
     * @return the cloudOwner
     */
    public String getCloudOwner() {
        return cloudOwner;
    }

    /**
     * @return the cloudRegionId
     */
    public String getCloudRegionId() {
        return cloudRegionId;
    }

    public boolean isValid() {
        return cloudOwner != null && !cloudOwner.isEmpty() && cloudRegionId != null && !cloudRegionId.isEmpty();
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (ObjectUtils.nullSafeHashCode(cloudOwner));
        result = prime * result + (ObjectUtils.nullSafeHashCode(cloudRegionId));

        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (obj instanceof CloudRegionKey) {
            final CloudRegionKey other = (CloudRegionKey) obj;
            return ObjectUtils.nullSafeEquals(cloudOwner, other.cloudOwner)
                    && ObjectUtils.nullSafeEquals(cloudRegionId, other.cloudRegionId);
        }
        return false;
    }

    @Override
    public String toString() {
        return "CloudRegionKey [cloudOwner=" + cloudOwner + ", cloudRegionId=" + cloudRegionId + "]";
    }

}
