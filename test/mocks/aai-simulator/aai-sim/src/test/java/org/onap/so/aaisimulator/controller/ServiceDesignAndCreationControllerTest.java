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

import org.junit.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.onap.aaisimulator.utils.TestConstants.SERVICE_DESIGN_AND_CREATION_URL;

@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT,
    properties = "SERVICE_DESIGN_AND_CREATION_RESPONSES_LOCATION=./src/test/resources/test-data/service-design-and-creation-responses")
public class ServiceDesignAndCreationControllerTest extends AbstractSpringBootTest{

  @Test
  public void should_reply_sample_modelvers_response() {
    final String url = getUrl(SERVICE_DESIGN_AND_CREATION_URL,
        "/models/model/a51e2bef-961c-496f-b235-b4540400e885/model-vers");
    ResponseEntity<String> actual = testRestTemplateService.invokeHttpGet(url, String.class);
    String expectedXml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" +
        "<model-vers xmlns=\"http://org.onap.aai.inventory/v11\">\n" +
        "    <model-ver>\n" +
        "        <model-version-id>c0818142-324d-4a8c-8065-45a61df247a5</model-version-id>\n" +
        "        <model-name>EricService</model-name>\n" +
        "        <model-version>1.0</model-version>\n" +
        "        <model-description>blah</model-description>\n" +
        "        <resource-version>1594657102313</resource-version>\n" +
        "    </model-ver>\n" +
        "    <model-ver>\n" +
        "        <model-version-id>4442dfc1-0d2d-46b4-b0bc-a2ac10448269</model-version-id>\n" +
        "        <model-name>EricService</model-name>\n" +
        "        <model-version>2.0</model-version>\n" +
        "        <model-description>blahhhh</model-description>\n" +
        "        <resource-version>1594707742646</resource-version>\n" +
        "    </model-ver>\n" +
        "</model-vers>";

    assertEquals(HttpStatus.OK, actual.getStatusCode());
    MediaType contentType = actual.getHeaders().getContentType();
    assertNotNull(contentType);
    assertTrue(contentType.isCompatibleWith(MediaType.APPLICATION_XML));
    assertEquals(expectedXml, actual.getBody());
  }
}