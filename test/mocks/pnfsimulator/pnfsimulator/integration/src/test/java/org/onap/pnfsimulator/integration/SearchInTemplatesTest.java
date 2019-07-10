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
import static java.nio.file.Files.readAllBytes;

import io.restassured.http.Header;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import org.hamcrest.Matchers;
import org.junit.BeforeClass;
import org.junit.Test;
import org.springframework.util.ResourceUtils;

public class SearchInTemplatesTest {

    private static final String UPLOAD = "upload";
    private static final String SEARCH = "search";
    private static final String APPLICATION_JSON = "application/json";
    private static final String CONTENT_TYPE = "Content-Type";

    @BeforeClass
    public static void setUp() throws IOException {
        for (File file : readFileFromTemplatesFolder()) {
            byte[] body = readAllBytes(file.toPath());

            given()
                .body(body)
                .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
                .when()
                .post(prepareRequestUrl(UPLOAD) + "?override=true")
                .then()
                .statusCode(201);
        }
    }

    @Test
    public void shouldFindNothingWhenNonexistentValueIsProvided(){
        given()
            .body("{\"searchExpr\": { \"child3\": \"nonexistentValue\" }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.empty());
    }

    @Test
    public void shouldFindNothingWhenNonexistentKeyIsProvided(){
        given()
            .body("{\"searchExpr\": { \"nonexistentKey\": \"Any value 1\" }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.empty());
    }

    @Test
    public void shouldFindNothingWhenPartOfKeyIsProvided(){
        given()
            .body("{\"searchExpr\": { \"child\": \"Any value 1\" }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.empty());
    }

    @Test
    public void shouldFindNothingWhenPartOfValueIsProvided(){
        given()
            .body("{\"searchExpr\": { \"child5\": \"Any\" }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.empty());
    }

    @Test
    public void shouldBeAbleToSearchForString(){
        given()
            .body("{\"searchExpr\": { \"child1\": \"Any value 1\" }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.hasItems("template_with_array.json", "complicated_template.json", "simple_template.json"));

        given()
            .body("{\"searchExpr\": { \"child2\": \"any value 4\" }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.hasItems("template_with_array.json"));
    }

    @Test
    public void shouldBeAbleToSearchForManyStrings(){
        given()
            .body("{\"searchExpr\": { \"child1\": \"Any value 1\",  \"child2\": \"any value 2\"}}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.hasItems("simple_template.json", "complicated_template.json"));
    }

    @Test
    public void shouldBeAbleToSearchForStarSign(){
        given()
            .body("{\"searchExpr\": { \"child2\": \"*\" }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.hasItems("complicated_template.json"));
    }

    @Test
    public void shouldBeAbleToSearchForQuestionMark(){
        given()
            .body("{\"searchExpr\": { \"child1\": \"?\" }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.hasItems("complicated_template.json"));
    }

    @Test
    public void shouldBeAbleToSearchForBrackets(){
        given()
            .body("{\"searchExpr\": { \"parent2\": \"[]\" }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.hasItems("template_with_array.json"));
    }

    @Test
    public void shouldInformThatSearchForNullsIsProhibited(){
        given()
            .body("{\"searchExpr\": { \"child3\":  null }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(400);
    }

    @Test
    public void shouldBeAbleToSearchForURI(){
        given()
            .body("{\"searchExpr\": { \"child3\": \"https://url.com?param1=test&param2=*\" }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.hasItems("complicated_template.json"));
    }

    @Test
    public void shouldBeAbleToSearchForFloats(){
        given()
            .body("{\"searchExpr\": { \"child2\": 4.44 }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.hasItems("template_with_array.json"));

        given()
            .body("{\"searchExpr\": { \"child5\": 4.4 }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.hasItems("complicated_template.json", "template_with_floats.json"));
    }

    @Test
    public void shouldBeAbleToSearchForIntegers(){
        given()
            .body("{\"searchExpr\": { \"child2\": 1 }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.hasItems("template_with_array.json", "template_with_ints.json"));

        given()
            .body("{\"searchExpr\": { \"child2\": 4 }}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.hasItems("template_with_array.json"));
    }

    @Test
    public void shouldBeAbleToSearchForBooleans(){
        given()
            .body("{\"searchExpr\": { \"child4\": true}}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.hasItems("template_with_booleans.json"));

        given()
            .body("{\"searchExpr\": { \"parent2\": false}}")
            .header(new Header(CONTENT_TYPE, APPLICATION_JSON))
            .when()
            .post(prepareRequestUrl(SEARCH))
            .then()
            .statusCode(200)
            .body("", Matchers.hasItems("template_with_booleans.json"));
    }


    private static String prepareRequestUrl(String action) {
        return "http://0.0.0.0:5000/template/" + action;
    }

    private static File[] readFileFromTemplatesFolder() throws FileNotFoundException {
        return ResourceUtils.getFile("classpath:templates/search").listFiles();
    }

}
