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
package org.onap.aaisimulator.utils;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Base64;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.util.UriComponentsBuilder;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.module.jaxb.JaxbAnnotationModule;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public class TestUtils {

    private static final String PASSWORD = "aai.onap.org:demo123456!";

    public static HttpHeaders getHttpHeaders(final String username) {
        final HttpHeaders requestHeaders = new HttpHeaders();
        requestHeaders.add("Authorization", getBasicAuth(username));
        requestHeaders.setContentType(MediaType.APPLICATION_JSON);
        return requestHeaders;
    }

    public static File getFile(final String file) throws IOException {
        return new ClassPathResource(file).getFile();
    }

    public static String getJsonString(final String file) throws IOException {
        return new String(Files.readAllBytes(getFile(file).toPath()));
    }

    public static <T> T getObjectFromFile(final File file, final Class<T> clazz) throws Exception {
        final ObjectMapper mapper = new ObjectMapper();
        mapper.registerModule(new JaxbAnnotationModule());

        return mapper.readValue(file, clazz);
    }

    public static String getBasicAuth(final String username) {
        return "Basic " + new String(Base64.getEncoder().encodeToString((username + ":" + PASSWORD).getBytes()));
    }

    public static String getBaseUrl(final int port) {
        return "https://localhost:" + port;
    }

    public static String getCustomer() throws Exception, IOException {
        return getJsonString("test-data/business-customer.json");
    }

    public static String getServiceSubscription() throws IOException {
        return getJsonString("test-data/service-subscription.json");
    }

    public static String getServiceInstance() throws IOException {
        return getJsonString("test-data/service-instance.json");
    }

    public static String getGenericVnf() throws IOException {
        return getJsonString("test-data/generic-vnf.json");
    }

    public static String getPnf() throws IOException {
        return getJsonString("test-data/pnf.json");
    }

    public static String getRelationShip() throws IOException {
        return getJsonString("test-data/relation-ship.json");
    }

    public static String getPlatformRelatedLink() throws IOException {
        return getJsonString("test-data/platform-related-link.json");
    }

    public static String getLineOfBusinessRelatedLink() throws IOException {
        return getJsonString("test-data/line-of-business-related-link.json");
    }

    public static String getPlatform() throws IOException {
        return getJsonString("test-data/platform.json");
    }

    public static String getGenericVnfRelationShip() throws IOException {
        return getJsonString("test-data/generic-vnf-relationship.json");
    }

    public static String getLineOfBusiness() throws IOException {
        return getJsonString("test-data/line-of-business.json");
    }

    public static String getBusinessProject() throws IOException {
        return getJsonString("test-data/business-project.json");
    }

    public static String getBusinessProjectRelationship() throws IOException {
        return getJsonString("test-data/business-project-relation-ship.json");
    }

    public static String getOwningEntityRelationship() throws IOException {
        return getJsonString("test-data/owning-entity-relation-ship.json");
    }

    public static String getOwningEntity() throws IOException {
        return getJsonString("test-data/owning-entity.json");
    }

    public static String getOrchStatuUpdateServiceInstance() throws IOException {
        return getJsonString("test-data/service-instance-orch-status-update.json");
    }

    public static String getRelationShipJsonObject() throws IOException {
        return getJsonString("test-data/service-Instance-relationShip.json");
    }

    public static String getCloudRegion() throws IOException {
        return getJsonString("test-data/cloud-region.json");
    }

    public static String getTenant() throws IOException {
        return getJsonString("test-data/tenant.json");
    }

    public static String getCloudRegionRelatedLink() throws IOException {
        return getJsonString("test-data/cloud-region-related-link.json");
    }

    public static String getGenericVnfRelatedLink() throws IOException {
        return getJsonString("test-data/generic-vnf-related-link.json");
    }

    public static String getTenantRelationShip() throws IOException {
        return getJsonString("test-data/tenant-relationship.json");
    }

    public static String getGenericVnfOrchStatuUpdate() throws IOException {
        return getJsonString("test-data/generic-vnf-orch-status-update.json");
    }

    public static String getEsrVnfm() throws IOException {
        return getJsonString("test-data/esr-vnfm.json");
    }

    public static String getEsrSystemInfo() throws IOException {
        return getJsonString("test-data/esr-system-info.json");
    }

    public static String getVserver() throws IOException {
        return getJsonString("test-data/vServer.json");
    }


    public static String getUrl(final int port, final String... urls) {
        final UriComponentsBuilder baseUri = UriComponentsBuilder.fromUriString("https://localhost:" + port);
        for (final String url : urls) {
            baseUri.path(url);
        }
        return baseUri.toUriString();
    }

    private TestUtils() {}

}
