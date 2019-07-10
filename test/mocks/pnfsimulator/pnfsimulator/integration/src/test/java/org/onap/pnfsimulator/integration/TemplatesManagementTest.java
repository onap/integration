/*-
 * ============LICENSE_START=======================================================
 * Simulator
 * ================================================================================
 * Copyright (C) 2019 Nokia. All rights reserved.
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
 * ============LICENSE_END=========================================================
 */

package org.onap.pnfsimulator.integration;

import static io.restassured.RestAssured.given;

import io.restassured.http.Header;
import io.restassured.path.json.JsonPath;
import io.restassured.path.json.config.JsonPathConfig;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;
import org.hamcrest.Matchers;
import org.json.JSONException;
import org.json.JSONObject;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.util.ResourceUtils;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = {Main.class, TestConfiguration.class}, webEnvironment = WebEnvironment.DEFINED_PORT)
public class TemplatesManagementTest {

    private static final String LIST_URL = "list";
    private static final String GET_URL = "get/";
    private static final String UPLOAD = "upload";
    private static final String NOTIFICATION_JSON = "notification.json";
    private static final String REGISTRATION_JSON = "registration.json";
    private static final String UPLOAD_TEMPLATE_JSON = "upload_template.json";
    private static final String OVERWRITE_TEMPLATE_JSON = "overwrite_template.json";
    private static final String OVERWRITTEN_TEMPLATE_JSON = "overwritten_template.json";
    private static final String APPLICATION_JSON = "application/json";
    private static final String CONTENT_TYPE = "Content-Type";
    private static final String FORCE_FLAG = "?override=true";
    private static final String CONTENT = "content";
    private static final String TEMPLATE = "template";
    private static final String ID = "id";

    @Test
    public void whenCallingGetShouldReceiveNotificationTemplate() throws IOException {
        given()
            .when()
            .get(prepareRequestUrl(GET_URL) + NOTIFICATION_JSON)
            .then()
            .statusCode(200)
            .body(ID, Matchers.equalTo(NOTIFICATION_JSON))
            .body(CONTENT, Matchers.equalTo(readTemplateFromResources(NOTIFICATION_JSON).getMap(CONTENT)));
    }

    @Test
    public void whenCallingGetShouldReceiveRegistrationTemplate() throws IOException {
        given()
            .when()
            .get(prepareRequestUrl(GET_URL) + REGISTRATION_JSON)
            .then()
            .statusCode(200)
            .body(ID, Matchers.equalTo(REGISTRATION_JSON))
            .body(CONTENT, Matchers.equalTo(readTemplateFromResources(REGISTRATION_JSON).getMap(CONTENT)));
    }

    @Test
    public void whenCallingListShouldReceiveAllPredefinedTemplates() throws IOException {
        Map<Object, Object> registration = readTemplateFromResources(REGISTRATION_JSON).getMap(CONTENT);
        Map<Object, Object> notification = readTemplateFromResources(NOTIFICATION_JSON).getMap(CONTENT);

        given()
            .when()
            .get(prepareRequestUrl(LIST_URL))
            .then()
            .statusCode(200)
            .body(CONTENT, Matchers.<Map>hasItems(
                registration,
                notification
            ));
    }

    @Test
    public void whenCallingUploadAndGetShouldReceiveNewTemplate() throws IOException {
        byte[] body = Files.readAllBytes(readFileFromTemplatesFolder(UPLOAD_TEMPLATE_JSON));

        given()
            .body(body)
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(UPLOAD))
            .then()
            .statusCode(201);

        given()
            .when()
            .get(prepareRequestUrl(GET_URL) + UPLOAD_TEMPLATE_JSON)
            .then()
            .statusCode(200)
            .body(ID, Matchers.equalTo(UPLOAD_TEMPLATE_JSON))
            .body(CONTENT, Matchers.equalTo(readTemplateFromResources(UPLOAD_TEMPLATE_JSON).getMap(TEMPLATE)));
    }

    @Test
    public void whenCallingOverrideAndGetShouldReceiveNewTemplate() throws IOException, JSONException {
        byte[] body = Files.readAllBytes(readFileFromTemplatesFolder(OVERWRITE_TEMPLATE_JSON));

        given()
            .body(body)
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(UPLOAD))
            .then()
            .statusCode(201);

        JSONObject overwrittenBody = new JSONObject(new String(body));
        JSONObject overwrittenTemplate = new JSONObject("{\"field1\": \"overwritten_field1\"}");
        overwrittenBody.put(TEMPLATE, overwrittenTemplate);

        given()
            .body(overwrittenBody.toString().getBytes())
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(UPLOAD))
            .then()
            .statusCode(409);

        given()
            .body(overwrittenBody.toString().getBytes())
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(UPLOAD + FORCE_FLAG))
            .then()
            .statusCode(201);

        given()
            .when()
            .get(prepareRequestUrl(GET_URL) + OVERWRITE_TEMPLATE_JSON)
            .then()
            .statusCode(200)
            .body(ID, Matchers.equalTo(OVERWRITE_TEMPLATE_JSON))
            .body(CONTENT, Matchers.equalTo(readTemplateFromResources(OVERWRITTEN_TEMPLATE_JSON).getMap(CONTENT)));
    }

    private String prepareRequestUrl(String action) {
        return "http://0.0.0.0:5000/template/" + action;
    }

    private JsonPath readTemplateFromResources(String templateName) throws IOException {
        byte[] content = Files.readAllBytes(readFileFromTemplatesFolder(templateName));
        return new JsonPath(new String(content)).using(new JsonPathConfig("UTF-8"));
    }

    private Path readFileFromTemplatesFolder(String templateName) throws FileNotFoundException {
        return ResourceUtils.getFile("classpath:templates/"+templateName).toPath();
    }

}
