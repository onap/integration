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

package org.onap.netconfsimulator.kafka;

import org.bitbucket.radistao.test.annotation.BeforeAllMethods;
import org.bitbucket.radistao.test.runner.BeforeAfterSpringTestRunner;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.test.context.EmbeddedKafka;
import org.springframework.kafka.test.rule.EmbeddedKafkaRule;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@RunWith(BeforeAfterSpringTestRunner.class)
@SpringBootTest(classes = {StoreService.class, EmbeddedKafkaConfig.class})
@EmbeddedKafka
public class StoreServiceTest {

    private static final String MESSAGE_1 = "message1";
    private static final String MESSAGE_2 = "message2";
    private static final String MESSAGE_3 = "message3";

    @ClassRule
    public static EmbeddedKafkaRule embeddedKafka = new EmbeddedKafkaRule(1, true, 1, "config");

    @Autowired
    StoreService service;

    @Autowired
    KafkaTemplate<String, String> kafkaTemplate;

    @BeforeAllMethods
    public void setupBeforeAll() {
        prepareProducer();
    }

    @Test
    public void testShouldReturnAllAvailableMessages(){

        List<MessageDTO> actualMessages = service.getAllMessages();

        assertResponseContainsExpectedMessages(actualMessages, 3, MESSAGE_1, MESSAGE_2, MESSAGE_3);
    }

    @Test
    public void testShouldGetLastMessagesRespectingOffset(){

        List<MessageDTO> wantedLastMsg = service.getLastMessages(1L);

        assertResponseContainsExpectedMessages(wantedLastMsg, 1, MESSAGE_3);
    }

    @Test
    public void testShouldGetAll3Messages()  {
        List<MessageDTO> wantedLastMsgs = service.getLastMessages(3L);

        assertResponseContainsExpectedMessages(wantedLastMsgs, 3, MESSAGE_1, MESSAGE_2, MESSAGE_3);
    }

    private void prepareProducer(){
        kafkaTemplate.send("config", "message1");
        kafkaTemplate.send("config", "message2");
        kafkaTemplate.send("config", "message3");
    }

    private void assertResponseContainsExpectedMessages(List<MessageDTO> actualMessages, int expectedMessageCount, String... expectedMessages){
        assertThat(actualMessages.stream().map(MessageDTO::getConfiguration))
                .hasSize(expectedMessageCount)
                .containsExactly(expectedMessages);
    }

}







