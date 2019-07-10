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

package integration;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.palantir.docker.compose.connection.DockerMachine;
import com.palantir.docker.compose.connection.waiting.HealthChecks;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.bitbucket.radistao.test.annotation.BeforeAllMethods;
import org.bitbucket.radistao.test.runner.BeforeAfterSpringTestRunner;
import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.rules.TestRule;
import org.junit.runner.RunWith;
import com.palantir.docker.compose.DockerComposeRule;
import org.onap.netconfsimulator.kafka.model.KafkaMessage;
import org.springframework.http.HttpStatus;

import java.io.IOException;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import static junit.framework.TestCase.fail;
import static org.assertj.core.api.Assertions.assertThat;

@RunWith(BeforeAfterSpringTestRunner.class)
public class NetconfFunctionsIT {

    private static NetconfSimulatorClient client;
    private static ObjectMapper objectMapper;

    private static final DockerMachine dockerMachine = DockerMachine
        .localMachine()
        .build();

    private static DockerComposeRule docker = DockerComposeRule.builder()
        .file("docker-compose.yml")
        .machine(dockerMachine)
        .removeConflictingContainersOnStartup(true)
        .waitingForService("sftp-server", HealthChecks.toHaveAllPortsOpen())
        .waitingForService("ftpes-server", HealthChecks.toHaveAllPortsOpen())
        .waitingForService("zookeeper", HealthChecks.toHaveAllPortsOpen())
        .waitingForService("netopeer", HealthChecks.toHaveAllPortsOpen())
        .waitingForService("kafka1", HealthChecks.toHaveAllPortsOpen())
        .waitingForService("netconf-simulator", HealthChecks.toHaveAllPortsOpen())
        .build();

    @ClassRule
    public static TestRule exposePortMappings = docker;

    @BeforeClass
    public static void setUpClass() {
        objectMapper = new ObjectMapper();
        client = new NetconfSimulatorClient(String.format("http://%s:%d", docker.containers().ip(), 9000));
    }

    @BeforeAllMethods
    public void setupBeforeAll() throws InterruptedException {
        if (client.isServiceAvailable(Instant.now(), Duration.ofSeconds(45))) {
            Thread.sleep(60000);
            return;
        }
        fail("Application failed to start within established timeout: 45 seconds. Exiting.");
    }

    @Before
    public void setUp() {
        client.reinitializeClient();
    }

    @After
    public void tearDown() throws Exception {
        client.releaseClient();
    }

    @Test
    public void testShouldLoadModelEditConfigurationAndDeleteModule() throws IOException {
        // do load
        try (CloseableHttpResponse response = client
            .loadModel("newyangmodel", "newYangModel.yang", "initialConfig.xml")) {
            assertResponseStatusCode(response, HttpStatus.OK);
            String original = client.getResponseContentAsString(response);
            assertThat(original).isEqualTo("\"Successfully started\"\n");
        }
        // do edit-config
        try (CloseableHttpResponse updateResponse = client.updateConfig()) {
            String afterUpdateConfigContent = client.getResponseContentAsString(updateResponse);
            assertResponseStatusCode(updateResponse, HttpStatus.ACCEPTED);
            assertThat(afterUpdateConfigContent).isEqualTo("New configuration has been activated");
        }
        // do delete
        try (CloseableHttpResponse deleteResponse = client.deleteModel("newyangmodel")) {
            assertResponseStatusCode(deleteResponse, HttpStatus.OK);
            String original = client.getResponseContentAsString(deleteResponse);
            assertThat(original).isEqualTo("\"Successfully deleted\"\n");
        }
    }

    @Test
    public void testShouldGetCurrentConfigurationAndEditItSuccessfully() throws IOException {
        try (CloseableHttpResponse updateResponse = client.updateConfig();
            CloseableHttpResponse newCurrentConfigResponse = client.getCurrentConfig()) {
            String afterUpdateConfigContent = client.getResponseContentAsString(updateResponse);

            assertResponseStatusCode(updateResponse, HttpStatus.ACCEPTED);
            assertResponseStatusCode(newCurrentConfigResponse, HttpStatus.OK);

            assertThat(afterUpdateConfigContent).isEqualTo("New configuration has been activated");
        }
    }

    @Test
    public void testShouldPersistConfigChangesAndGetAllWhenRequested() throws IOException {
        client.updateConfig();

        try (CloseableHttpResponse newAllConfigChangesResponse = client.getAllConfigChanges()) {
            String newAllConfigChangesString = client.getResponseContentAsString(newAllConfigChangesResponse);
            assertResponseStatusCode(newAllConfigChangesResponse, HttpStatus.OK);

            List<KafkaMessage> kafkaMessages = objectMapper
                .readValue(newAllConfigChangesString, new TypeReference<List<KafkaMessage>>() {
                });

            assertThat(kafkaMessages.size()).isGreaterThanOrEqualTo(1);
            Set<String> configChangeContent = kafkaMessages.stream().map(KafkaMessage::getConfiguration)
                .collect(Collectors.toSet());
            assertThat(configChangeContent)
                .anyMatch(el -> el.contains("new value: /pnf-simulator:config/itemValue1 = 100"));
            assertThat(configChangeContent)
                .anyMatch(el -> el.contains("new value: /pnf-simulator:config/itemValue2 = 200"));
        }
    }

    @Test
    public void testShouldGetLastMessage() throws IOException {
        client.updateConfig();

        try (CloseableHttpResponse lastConfigChangesResponse = client.getLastConfigChanges(2)) {
            String newAllConfigChangesString = client.getResponseContentAsString(lastConfigChangesResponse);
            List<KafkaMessage> kafkaMessages = objectMapper
                .readValue(newAllConfigChangesString, new TypeReference<List<KafkaMessage>>() {
                });

            assertThat(kafkaMessages).hasSize(2);
            assertThat(kafkaMessages.get(0).getConfiguration())
                .contains("new value: /pnf-simulator:config/itemValue1 = 100");
            assertThat(kafkaMessages.get(1).getConfiguration())
                .contains("new value: /pnf-simulator:config/itemValue2 = 200");
        }
    }

    @Test
    public void testShouldLoadNewYangModelAndReconfigure() throws IOException {
        try (CloseableHttpResponse response = client
            .loadModel("newyangmodel", "newYangModel.yang", "initialConfig.xml")) {
            assertResponseStatusCode(response, HttpStatus.OK);

            String original = client.getResponseContentAsString(response);

            assertThat(original).isEqualTo("\"Successfully started\"\n");
        }
    }

    @Test
    public void shouldGetLoadedModelByName() throws IOException {
        testShouldLoadNewYangModelAndReconfigure();

        try (CloseableHttpResponse response = client.getConfigByModelAndContainerNames("newyangmodel", "config2")) {
            assertResponseStatusCode(response, HttpStatus.OK);
            String config = client.getResponseContentAsString(response);

            assertThat(config).isEqualTo(
                "<config2 xmlns=\"http://onap.org/newyangmodel\" xmlns:nc=\"urn:ietf:params:xml:ns:netconf:base:1.0\">\n"
                    + "  <item1>100</item1>\n"
                    + "</config2>\n");
        }

    }

    private void assertResponseStatusCode(HttpResponse response, HttpStatus expectedStatus) {
        assertThat(response.getStatusLine().getStatusCode()).isEqualTo(expectedStatus.value());
    }

}
