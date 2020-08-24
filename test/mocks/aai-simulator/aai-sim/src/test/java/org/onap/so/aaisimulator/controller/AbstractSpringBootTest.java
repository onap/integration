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

import java.util.List;
import org.junit.runner.RunWith;
import org.onap.aai.domain.yang.RelatedToProperty;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.aaisimulator.utils.TestRestTemplateService;
import org.onap.aaisimulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.context.annotation.Configuration;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ActiveProfiles("test")
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@Configuration
public abstract class AbstractSpringBootTest {

    @LocalServerPort
    private int port;

    @Autowired
    protected TestRestTemplateService testRestTemplateService;

    public String getUrl(final String... urls) {
        return TestUtils.getUrl(port, urls);
    }

    public RelationshipData getRelationshipData(final List<RelationshipData> relationshipData, final String key) {
        return relationshipData.stream().filter(data -> data.getRelationshipKey().equals(key)).findFirst().orElse(null);
    }

    public RelatedToProperty getRelatedToProperty(final List<RelatedToProperty> relatedToPropertyList,
            final String key) {
        return relatedToPropertyList.stream().filter(data -> data.getPropertyKey().equals(key)).findFirst()
                .orElse(null);
    }
}
