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
import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
import static org.hamcrest.Matchers.equalTo;

import com.google.gson.JsonObject;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientOptions;
import com.mongodb.MongoCredential;
import com.mongodb.ServerAddress;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import java.time.Instant;
import java.net.Inet4Address;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.Collections;
import org.assertj.core.api.Assertions;
import org.bson.Document;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = {Main.class, TestConfiguration.class}, webEnvironment = WebEnvironment.DEFINED_PORT)
public class OptionalTemplatesTest {

    private static final String PNF_SIMULATOR_DB = "pnf_simulator";
    private static final String COMMON_EVENT_HEADER = "commonEventHeader";
    private static final String PNF_SIMULATOR_DB_PSWD = "zXcVbN123!";
    private static final String PNF_SIMULATOR_DB_USER = "pnf_simulator_user";
    private static final String PATCHED = "patched";
    private static final String SINGLE_EVENT_URL = "http://0.0.0.0:5000/simulator/event";

    @Autowired
    VesSimulatorController vesSimulatorController;

    @Autowired
    private VesSimulatorService vesSimulatorService;

    private String currentVesSimulatorIp;

    @Before
    public void setUp() throws Exception {
        currentVesSimulatorIp = getCurrentIpAddress();
    }

    @After
    public void tearDown() {
        Mockito.reset(vesSimulatorService);
    }

    @Test
    public void whenTriggeredSimulatorWithoutTemplateShouldSendSingleEventToVes() {
        //given
        long currentTimestamp = Instant.now().getEpochSecond();

        String body = "{\n"
            + "\"vesServerUrl\": \"https://" + currentVesSimulatorIp + ":9443/ves-simulator/eventListener/v5\",\n"
            + "\"event\": { \n"
            + "\"commonEventHeader\": {\n"
            + "\"eventId1\": \"#RandomString(20)\",\n"
            + "\"eventId2\": \"#RandomInteger(10,10)\",\n"
            + "\"eventId3\": \"#Increment\",\n"
            + "\"eventId4\": \"#RandomPrimitiveInteger(10,10)\",\n"
            + "\"eventId5\": \"#TimestampPrimitive\",\n"
            + "\"sourceName\": \"Single_sourceName\",\n"
            + "\"version\": 3"
            + "}\n"
            + "}\n"
            + "}";
        ArgumentCaptor<JsonObject> parameterCaptor = ArgumentCaptor.forClass(JsonObject.class);

        //when
        given()
            .contentType("application/json")
            .body(body)
            .when()
            .post(SINGLE_EVENT_URL)
            .then()
            .statusCode(202)
            .body("message", equalTo("One-time direct event sent successfully"));

        //then
        long afterExecution = Instant.now().getEpochSecond();
        Mockito.verify(vesSimulatorService,
            Mockito.timeout(3000))
            .sendEventToDmaapV5(parameterCaptor.capture());

        JsonObject value = parameterCaptor.getValue();
        assertThat(value
            .getAsJsonObject(COMMON_EVENT_HEADER)
            .get("sourceName").getAsString()).isEqualTo("Single_sourceName");
        assertThat(value
            .getAsJsonObject(COMMON_EVENT_HEADER)
            .get("eventId1").getAsString().length()).isEqualTo(20);
        assertThat(value
            .getAsJsonObject(COMMON_EVENT_HEADER)
            .get("eventId2").getAsString()).isEqualTo("10");
        assertThat(value
            .getAsJsonObject(COMMON_EVENT_HEADER)
            .get("eventId3").getAsString()).isEqualTo("1");
        assertThat(value
            .getAsJsonObject(COMMON_EVENT_HEADER)
            .get("eventId4").getAsInt()).isEqualTo(10);
        assertThat(value
            .getAsJsonObject(COMMON_EVENT_HEADER)
            .get("eventId5").getAsLong()).isBetween(currentTimestamp, afterExecution);
    }

    @Test
    public void whenTriggeredSimulatorWithoutTemplateEventShouldBeVisibleInDB() throws UnknownHostException {
        //given
        String body = "{\n"
            + "\"vesServerUrl\": \"https://" + currentVesSimulatorIp + ":9443/ves-simulator/eventListener/v5\",\n"
            + "\"event\": { \n"
            + "\"commonEventHeader\": {\n"
            + "\"sourceName\": \"HistoricalEvent\",\n"
            + "\"version\": 3"
            + "}\n"
            + "}\n"
            + "}";
        ArgumentCaptor<JsonObject> parameterCaptor = ArgumentCaptor.forClass(JsonObject.class);

        //when
        given()
            .contentType("application/json")
            .body(body)
            .when()
            .post(SINGLE_EVENT_URL)
            .then()
            .statusCode(202)
            .body("message", equalTo("One-time direct event sent successfully"));

        //then
        Mockito.verify(vesSimulatorService,
            Mockito.timeout(3000))
            .sendEventToDmaapV5(parameterCaptor.capture());

        Document sourceNameInMongoDB = findSourceNameInMongoDB();
        Assertions.assertThat(sourceNameInMongoDB.get(PATCHED))
            .isEqualTo("{\"commonEventHeader\":{\"sourceName\":\"HistoricalEvent\",\"version\":3}}");
    }

    private Document findSourceNameInMongoDB() throws UnknownHostException {
        MongoCredential credential = MongoCredential
            .createCredential(PNF_SIMULATOR_DB_USER, PNF_SIMULATOR_DB, PNF_SIMULATOR_DB_PSWD.toCharArray());
        MongoClient mongoClient = new MongoClient(new ServerAddress(Inet4Address.getLocalHost(), 27017),
            credential, MongoClientOptions.builder().build());
        MongoDatabase pnfSimulatorDb = mongoClient.getDatabase(PNF_SIMULATOR_DB);
        MongoCollection<Document> table = pnfSimulatorDb.getCollection("eventData");
        Document searchQuery = new Document();
        searchQuery.put(PATCHED, new Document("$regex", ".*" + "HistoricalEvent" + ".*"));
        FindIterable<Document> findOfPatched = table.find(searchQuery);
        Document dbObject = null;
        MongoCursor<Document> cursor = findOfPatched.iterator();
        if (cursor.hasNext()) {
            dbObject = cursor.next();
        }
        return dbObject;
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
