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

import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.common.TopicPartition;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Slf4j
@Service
public class StoreService {

    private static final String CONFIG_TOPIC = "config";
    private static final long CONSUMING_DURATION_IN_MS = 1000;

    private ConsumerFactory<String, String> consumerFactory;
    static final List<String> TOPICS_TO_SUBSCRIBE = Collections.singletonList(CONFIG_TOPIC);

    @Autowired
    StoreService(ConsumerFactory<String, String> consumerFactory) {
        this.consumerFactory = consumerFactory;
    }

    List<MessageDTO> getAllMessages() {
        List<MessageDTO> messages = new ArrayList<>();
        String clientID = Long.toString(Instant.now().getEpochSecond());
        try (Consumer<String, String> consumer = consumerFactory.createConsumer(clientID, clientID)) {
            consumer.subscribe(TOPICS_TO_SUBSCRIBE);
            ConsumerRecords<String, String> consumerRecords = consumer.poll(CONSUMING_DURATION_IN_MS);
            consumerRecords.forEach(
                consumerRecord ->
                    messages.add(new MessageDTO(consumerRecord.timestamp(), consumerRecord.value())));
            log.debug(String.format("consumed %d messages", consumerRecords.count()));
            }
        return messages;
    }

    List<MessageDTO> getLastMessages(long offset) {
        List<MessageDTO> messages = new ArrayList<>();
        try (Consumer<String, String> consumer = createConsumer(offset)) {
            ConsumerRecords<String, String> consumerRecords = consumer.poll(CONSUMING_DURATION_IN_MS);
            consumerRecords.forEach(consumerRecord ->
                    messages.add(new MessageDTO(consumerRecord.timestamp(), consumerRecord.value())));
        }
        return messages;
    }

    private Consumer<String, String> createConsumer(long offsetFromLastIndex) {
        String clientID = Long.toString(Instant.now().getEpochSecond());
        Consumer<String, String> consumer = consumerFactory.createConsumer(clientID, clientID);
        consumer.subscribe(TOPICS_TO_SUBSCRIBE);
        seekConsumerTo(consumer, offsetFromLastIndex);
        return consumer;
    }

    private void seekConsumerTo(Consumer<String, String> consumer, long offsetFromLastIndex) {
        consumer.seekToEnd(consumer.assignment());
        consumer.poll(CONSUMING_DURATION_IN_MS);
        TopicPartition topicPartition = consumer.assignment().iterator().next();
        long topicCurrentSize = consumer.position(topicPartition);
        long indexToSeek = offsetFromLastIndex > topicCurrentSize ? 0 : topicCurrentSize - offsetFromLastIndex;
        consumer.seek(topicPartition, indexToSeek);
    }
}
