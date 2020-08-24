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

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public class NodeServiceInstance implements Serializable {

    private static final long serialVersionUID = -3314166327618070948L;

    private String globalCustomerId;
    private String serviceType;
    private String serviceInstanceId;
    private String resourceType;
    private String resourceLink;

    public NodeServiceInstance() {}


    public NodeServiceInstance(final String globalCustomerId, final String serviceType, final String serviceInstanceId,
            final String resourceType, final String resourceLink) {
        this.globalCustomerId = globalCustomerId;
        this.serviceType = serviceType;
        this.serviceInstanceId = serviceInstanceId;
        this.resourceType = resourceType;
        this.resourceLink = resourceLink;
    }


    /**
     * @return the globalCustomerId
     */
    public String getGlobalCustomerId() {
        return globalCustomerId;
    }


    /**
     * @param globalCustomerId the globalCustomerId to set
     */
    public void setGlobalCustomerId(final String globalCustomerId) {
        this.globalCustomerId = globalCustomerId;
    }


    /**
     * @return the serviceType
     */
    public String getServiceType() {
        return serviceType;
    }


    /**
     * @param serviceType the serviceType to set
     */
    public void setServiceType(final String serviceType) {
        this.serviceType = serviceType;
    }


    /**
     * @return the serviceInstanceId
     */
    public String getServiceInstanceId() {
        return serviceInstanceId;
    }


    /**
     * @param serviceInstanceId the serviceInstanceId to set
     */
    public void setServiceInstanceId(final String serviceInstanceId) {
        this.serviceInstanceId = serviceInstanceId;
    }


    /**
     * @return the resourceType
     */
    public String getResourceType() {
        return resourceType;
    }


    /**
     * @param resourceType the resourceType to set
     */
    public void setResourceType(final String resourceType) {
        this.resourceType = resourceType;
    }


    /**
     * @return the resourceLink
     */
    public String getResourceLink() {
        return resourceLink;
    }


    /**
     * @param resourceLink the resourceLink to set
     */
    public void setResourceLink(final String resourceLink) {
        this.resourceLink = resourceLink;
    }


    @Override
    public String toString() {
        return "NodeServiceInstance [globalCustomerId=" + globalCustomerId + ", serviceType=" + serviceType
                + ", serviceInstanceId=" + serviceInstanceId + ", resourceType=" + resourceType + ", resourceLink="
                + resourceLink + "]";
    }


}
