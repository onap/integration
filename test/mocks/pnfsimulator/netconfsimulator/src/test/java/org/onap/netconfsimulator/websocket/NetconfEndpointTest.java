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

package org.onap.netconfsimulator.websocket;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.MockitoAnnotations.initMocks;

import java.util.Map;
import java.util.Optional;
import javax.websocket.CloseReason;
import javax.websocket.EndpointConfig;
import javax.websocket.RemoteEndpoint;
import javax.websocket.Session;
import org.apache.kafka.common.Metric;
import org.apache.kafka.common.MetricName;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.onap.netconfsimulator.kafka.listener.KafkaListenerEntry;
import org.onap.netconfsimulator.kafka.listener.KafkaListenerHandler;
import org.onap.netconfsimulator.websocket.message.NetconfMessageListener;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.listener.AbstractMessageListenerContainer;

import org.springframework.kafka.listener.ContainerProperties;
import org.springframework.kafka.listener.GenericMessageListener;

class NetconfEndpointTest {


    @Mock
    private KafkaListenerHandler kafkaListenerHandler;

    @Mock
    private Session session;

    @Mock
    private EndpointConfig endpointConfig;

    @Mock
    private RemoteEndpoint.Basic remoteEndpoint;


    @BeforeEach
    void setUp() {
        initMocks(this);
    }


    @Test
    void shouldCreateKafkaListenerWhenClientInitializeConnection() {
        NetconfEndpoint netconfEndpoint = new NetconfEndpoint(kafkaListenerHandler);
        AbstractMessageListenerContainer abstractMessageListenerContainer = getListenerContainer();
        when(session.getBasicRemote()).thenReturn(remoteEndpoint);
        KafkaListenerEntry kafkaListenerEntry = new KafkaListenerEntry("sampleGroupId",
            abstractMessageListenerContainer);
        when(kafkaListenerHandler.createKafkaListener(any(NetconfMessageListener.class), eq("config")))
            .thenReturn(kafkaListenerEntry);

        netconfEndpoint.onOpen(session, endpointConfig);

        assertThat(netconfEndpoint.getEntry().get().getClientId()).isEqualTo("sampleGroupId");
        assertThat(netconfEndpoint.getEntry().get().getListenerContainer()).isEqualTo(abstractMessageListenerContainer);

        verify(abstractMessageListenerContainer).start();
    }


    @Test
    void shouldCloseListenerWhenClientDisconnects() {
        NetconfEndpoint netconfEndpoint = new NetconfEndpoint(kafkaListenerHandler);
        AbstractMessageListenerContainer abstractMessageListenerContainer = getListenerContainer();
        netconfEndpoint.setEntry( Optional.of(new KafkaListenerEntry("sampleGroupId", abstractMessageListenerContainer)) );

        netconfEndpoint.onClose(session, mock(CloseReason.class));

        verify(abstractMessageListenerContainer).stop();
    }

    class TestAbstractMessageListenerContainer extends AbstractMessageListenerContainer {


        TestAbstractMessageListenerContainer(ContainerProperties containerProperties) {
            super(mock(ConsumerFactory.class),containerProperties);
        }

        @Override
        protected void doStart() {

        }

        @Override
        protected void doStop(Runnable callback) {

        }

        @Override
        public Map<String, Map<MetricName, ? extends Metric>> metrics() {
            return null;
        }
    }

    private AbstractMessageListenerContainer getListenerContainer() {
        ContainerProperties containerProperties = new ContainerProperties("config");
        containerProperties.setGroupId("sample");
        containerProperties.setMessageListener(mock(GenericMessageListener.class));
        TestAbstractMessageListenerContainer testAbstractMessageListenerContainer = new TestAbstractMessageListenerContainer(
            containerProperties);
        return spy(testAbstractMessageListenerContainer);
    }
}
