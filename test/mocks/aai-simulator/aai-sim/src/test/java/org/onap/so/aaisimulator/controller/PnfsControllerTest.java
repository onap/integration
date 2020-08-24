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
package org.onap.aaisimulator.controller;

import org.junit.After;
import org.junit.Test;
import org.onap.aai.domain.yang.v15.Pnf;
import org.onap.aaisimulator.service.providers.PnfCacheServiceProvider;
import org.onap.aaisimulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;


/**
 * @author Raj Gumma (raj.gumma@est.tech)
 *
 */
public class PnfsControllerTest extends AbstractSpringBootTest {

    @Autowired
    private PnfCacheServiceProvider cacheServiceProvider;

    private final String PNF="test-008";
    private final String PNF_URL= "/aai/v15/network/pnfs/pnf/";


    @After
    public void after() {
        cacheServiceProvider.clearAll();
    }

    @Test
    public void test_pnf_successfullyAddedToCache() throws Exception {

        final String url = getUrl(PNF_URL, PNF);
        final ResponseEntity<Void> pnfResponse =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getPnf(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, pnfResponse.getStatusCode());

        final ResponseEntity<Pnf> response =
                testRestTemplateService.invokeHttpGet(url, Pnf.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final Pnf actualPnf = response.getBody();
        assertEquals("test-008", actualPnf.getPnfName());
        assertEquals("5f2602dc-f647-4535-8f1d-9ec079e68a49", actualPnf.getPnfId());

    }
}
