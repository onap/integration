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
import static io.restassured.RestAssured.when;
import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
import static org.hamcrest.Matchers.equalTo;

import com.google.gson.JsonObject;
import java.io.IOException;
import java.net.Inet4Address;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Collections;
import java.util.UUID;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;
import org.mockito.internal.util.Timer;
import org.mockito.internal.verification.VerificationOverTimeImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = {Main.class, TestConfiguration.class}, webEnvironment = WebEnvironment.DEFINED_PORT)
public class BasicAvailabilityTest {

    @Autowired
    VesSimulatorController vesSimulatorController;

    @Autowired
    VesSimulatorService vesSimulatorService;

    private final String ACTION_START = "start";

    private String currenVesSimulatorIp;

    @Before
    public void setUp() throws Exception {
        currenVesSimulatorIp = getCurrentIpAddress();
    }

    @After
    public void tearDown() {
        Mockito.reset(vesSimulatorService);
    }

    @Test
    public void simulatorShouldFailWhenTriggeredNonexistentTemplate(){
        //given
        String startUrl = prepareRequestUrl(ACTION_START);
        String body = "{\n"
            + "\"templateName\": \"any_nonexistent_template.json\",\n"
            + "\"patch\":{},\n"
            + "\"simulatorParams\": {\n"
            + "\"vesServerUrl\": \"https://" + currenVesSimulatorIp + ":9443/ves-simulator/eventListener/v5\",\n"
            + "\"repeatInterval\": 1,\n"
            + "\"repeatCount\": 1\n"
            + "}\n"
            + "}";

        //when
        given()
            .contentType("application/json")
            .body(body)
            .when()
            .post(startUrl)
            .then()
            .statusCode(400)
            .body("message", equalTo("Cannot start simulator - template any_nonexistent_template.json not found."));
    }

    @Test
    public void whenTriggeredSimulatorShouldSendSingleEventToVes() {
        //given
        String startUrl = prepareRequestUrl(ACTION_START);
        String body = "{\n"
            + "\"templateName\": \"notification.json\",\n"
            + "\"patch\":{},\n"
            + "\"simulatorParams\": {\n"
            + "\"vesServerUrl\": \"https://" + currenVesSimulatorIp + ":9443/ves-simulator/eventListener/v5\",\n"
            + "\"repeatInterval\": 1,\n"
            + "\"repeatCount\": 1\n"
            + "}\n"
            + "}";
        ArgumentCaptor<JsonObject> parameterCaptor = ArgumentCaptor.forClass(JsonObject.class);

        //when
        given()
            .contentType("application/json")
            .body(body)
            .when()
            .post(startUrl)
            .then()
            .statusCode(200)
            .body("message", equalTo("Request started"));

        Mockito.verify(vesSimulatorService,
            Mockito.timeout(3000))
            .sendEventToDmaapV5(parameterCaptor.capture());

        assertThat(parameterCaptor.getValue()
            .getAsJsonObject("event")
            .getAsJsonObject("commonEventHeader")
            .get("domain").getAsString()).isEqualTo("notification");
    }

    @Test
    public void simulatorShouldCorrectlyRespondOnCancellAllEvent() {
        //given
        String ACTION_CANCEL_ALL = "cancel";
        String cancelAllUrl = prepareRequestUrl(ACTION_CANCEL_ALL);

        //when
        when()
            .post(cancelAllUrl)
            .then()
            .statusCode(200)
            .body("message", equalTo("Event(s) was cancelled"));

    }

    @Test
    public void simulatorBeAbleToUseNewlyAddedTemplate() throws IOException {
        //given
        String templateBody = "{\"fake\":\"template\"}\n";
        String fileName = UUID.randomUUID() + ".json";
        String requestBody = "{\n"
            + "\"templateName\": \"" + fileName + "\",\n"
            + "\"patch\":{},\n"
            + "\"simulatorParams\": {\n"
            + "\"vesServerUrl\": \"https://" + currenVesSimulatorIp + ":9443/ves-simulator/eventListener/v5\",\n"
            + "\"repeatInterval\": 1,\n"
            + "\"repeatCount\": 1\n"
            + "}\n"
            + "}";
        ArgumentCaptor<JsonObject> parameterCaptor = ArgumentCaptor.forClass(JsonObject.class);

        //when
        Path newFile = Files.createFile(Paths.get("..", "templates", fileName));
        Files.write(newFile, templateBody.getBytes());

        given()
            .contentType("application/json")
            .body(requestBody)
            .when()
            .post(prepareRequestUrl(ACTION_START));

        Files.delete(newFile);

        //then
        Mockito.verify(vesSimulatorService, Mockito.timeout(3000))
            .sendEventToDmaapV5(parameterCaptor.capture());
        assertThat(parameterCaptor.getValue()
            .get("fake").getAsString()).isEqualTo("template");

    }

    @Test
    public void whenTriggeredSimulatorShouldSendGivenAmountOfEventsToVes() {
        //given
        String startUrl = prepareRequestUrl(ACTION_START);
        String body = "{\n"
            + "\"templateName\": \"notification.json\",\n"
            + "\"patch\":{},\n"
            + "\"simulatorParams\": {\n"
            + "\"vesServerUrl\": \"https://" + currenVesSimulatorIp + ":9443/ves-simulator/eventListener/v5\",\n"
            + "\"repeatInterval\": 1,\n"
            + "\"repeatCount\": 4\n"
            + "}\n"
            + "}";
        ArgumentCaptor<JsonObject> parameterCaptor = ArgumentCaptor.forClass(JsonObject.class);

        //when
        given()
            .contentType("application/json")
            .body(body)
            .when()
            .post(startUrl)
            .then()
            .statusCode(200)
            .body("message", equalTo("Request started"));

        VerificationOverTimeImpl verificator = new VerificationOverTimeImpl(100, Mockito.times(4), false, new Timer(6000));
        Mockito.verify(vesSimulatorService, verificator).sendEventToDmaapV5(parameterCaptor.capture());

        for (JsonObject value : parameterCaptor.getAllValues()) {
            assertThat(value
                .getAsJsonObject("event")
                .getAsJsonObject("commonEventHeader")
                .get("domain").getAsString()).isEqualTo("notification");
        }
    }

    private String prepareRequestUrl(String action) {
        return "http://0.0.0.0:5000/simulator/" + action;
    }

    private String getCurrentIpAddress() throws SocketException {
        return Collections.list(NetworkInterface.getNetworkInterfaces()).stream()
            .flatMap(i -> Collections.list(i.getInetAddresses()).stream())
            .filter(ip -> ip instanceof Inet4Address)
            .map(e -> (Inet4Address) e)
            .findFirst()
            .orElseThrow(RuntimeException::new)
            .getHostAddress();
    }
}
