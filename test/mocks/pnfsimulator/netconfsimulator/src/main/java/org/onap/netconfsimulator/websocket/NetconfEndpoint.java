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


import java.util.Optional;
import javax.websocket.CloseReason;
import javax.websocket.Endpoint;
import javax.websocket.EndpointConfig;
import javax.websocket.RemoteEndpoint;
import javax.websocket.Session;

import org.onap.netconfsimulator.kafka.listener.KafkaListenerEntry;
import org.onap.netconfsimulator.kafka.listener.KafkaListenerHandler;
import org.onap.netconfsimulator.websocket.message.NetconfMessageListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.listener.AbstractMessageListenerContainer;
import org.springframework.kafka.listener.MessageListener;
import org.springframework.stereotype.Component;

//instance of this class is created every each websocket request
@Component
class NetconfEndpoint extends Endpoint {

    private static final Logger LOGGER = LoggerFactory.getLogger(NetconfEndpoint.class);
    private static final String TOPIC_NAME = "config";

    private KafkaListenerHandler kafkaListenerHandler;

    public Optional<KafkaListenerEntry> getEntry() {
        return entry;
    }

    public void setEntry(Optional<KafkaListenerEntry> entry) {
        this.entry = entry;
    }

    private Optional<KafkaListenerEntry> entry = Optional.empty();


    @Autowired
    NetconfEndpoint(KafkaListenerHandler listenerHandler) {
        this.kafkaListenerHandler = listenerHandler;
    }

    @Override
    public void onOpen(Session session, EndpointConfig endpointConfig) {
        RemoteEndpoint.Basic basicRemote = session.getBasicRemote();

        addKafkaListener(basicRemote);
        entry.ifPresent(x -> LOGGER.info("Session with client: {} established", x.getClientId()));
    }

    @Override
    public void onError(Session session, Throwable throwable) {
        LOGGER.error("Unexpected error occurred", throwable);
    }

    @Override
    public void onClose(Session session, CloseReason closeReason) {
        entry.ifPresent(x -> x.getListenerContainer().stop());
        entry.ifPresent(x -> LOGGER.info("Closing connection for client: {}", x.getClientId()));
    }


    private void addKafkaListener(RemoteEndpoint.Basic remoteEndpoint) {
        MessageListener messageListener = new NetconfMessageListener(remoteEndpoint);

        KafkaListenerEntry kafkaListener = kafkaListenerHandler.createKafkaListener(messageListener, TOPIC_NAME);

        AbstractMessageListenerContainer listenerContainer = kafkaListener.getListenerContainer();
        listenerContainer.start();
        entry = Optional.of(kafkaListener);
    }
}
