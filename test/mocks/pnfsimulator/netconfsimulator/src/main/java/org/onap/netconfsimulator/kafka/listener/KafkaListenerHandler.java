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

package org.onap.netconfsimulator.kafka.listener;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.ConsumerFactory;

import org.springframework.kafka.listener.ContainerProperties;
import org.springframework.kafka.listener.KafkaMessageListenerContainer;
import org.springframework.kafka.listener.MessageListener;


import org.springframework.kafka.support.TopicPartitionInitialOffset;

import java.time.Instant;

public class KafkaListenerHandler {

    private static final int PARTITION = 0;
    private static final long NUMBER_OF_HISTORICAL_MESSAGES_TO_SHOW = -10L;
    private static final boolean RELATIVE_TO_CURRENT = false;
    private ConsumerFactory<String, String> consumerFactory;


    @Autowired
    public KafkaListenerHandler(ConsumerFactory<String, String> consumerFactory) {
        this.consumerFactory = consumerFactory;
    }


    public KafkaListenerEntry createKafkaListener(MessageListener messageListener, String topicName) {
        String clientId = Long.toString(Instant.now().getEpochSecond());
        ContainerProperties containerProperties = new ContainerProperties(topicName);
        containerProperties.setGroupId(clientId);
        KafkaMessageListenerContainer<String, String> listenerContainer = createListenerContainer(containerProperties,
            topicName);

        listenerContainer.setupMessageListener(messageListener);
        return new KafkaListenerEntry(clientId, listenerContainer);
    }


    KafkaMessageListenerContainer<String, String> createListenerContainer(ContainerProperties containerProperties,
        String topicName) {
        TopicPartitionInitialOffset config = new TopicPartitionInitialOffset(topicName, PARTITION,
            NUMBER_OF_HISTORICAL_MESSAGES_TO_SHOW, RELATIVE_TO_CURRENT);
        return new KafkaMessageListenerContainer<>(consumerFactory, containerProperties, config);
    }
}
