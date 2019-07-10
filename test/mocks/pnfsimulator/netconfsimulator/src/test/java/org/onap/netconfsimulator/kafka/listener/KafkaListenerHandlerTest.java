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

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.MockitoAnnotations.initMocks;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.listener.ContainerProperties;
import org.springframework.kafka.listener.KafkaMessageListenerContainer;
import org.springframework.kafka.listener.MessageListener;

class KafkaListenerHandlerTest {

    private static final String CLIENT_ID_REGEX = "[0-9]{10,}";
    private static final String SAMPLE_TOPIC = "sampleTopic";

    @Mock
    private ConsumerFactory<String, String> consumerFactory;

    @Mock
    private KafkaMessageListenerContainer<String, String> kafkaMessageListenerContainer;

    @Mock
    private MessageListener messageListener;

    @BeforeEach
    void setUp() {
        initMocks(this);
    }


    @Test
    void shouldProperlyCreateKafkaListener() {
        KafkaListenerHandler kafkaListenerHandler = spy(new KafkaListenerHandler(consumerFactory));
        doReturn(kafkaMessageListenerContainer).when(kafkaListenerHandler)
            .createListenerContainer(any(ContainerProperties.class), eq(SAMPLE_TOPIC));

        KafkaListenerEntry kafkaListenerEntry = kafkaListenerHandler
            .createKafkaListener(messageListener, SAMPLE_TOPIC);

        assertThat(kafkaListenerEntry.getListenerContainer()).isEqualTo(kafkaMessageListenerContainer);
        assertThat(kafkaListenerEntry.getClientId()).matches(CLIENT_ID_REGEX);
    }

    @Test
    void shouldProperlyCreateContainer() {
        KafkaListenerHandler kafkaListenerHandler = spy(new KafkaListenerHandler(consumerFactory));
        ContainerProperties containerProperties = new ContainerProperties(SAMPLE_TOPIC);
        containerProperties.setMessageListener(mock(MessageListener.class));

        KafkaMessageListenerContainer<String, String> listenerContainer = kafkaListenerHandler
            .createListenerContainer(containerProperties, SAMPLE_TOPIC);

        ContainerProperties actualProperties = listenerContainer.getContainerProperties();
        assertThat(actualProperties.getTopics()).isEqualTo(containerProperties.getTopics());
        assertThat(actualProperties.getMessageListener()).isEqualTo(containerProperties.getMessageListener());
    }


}
