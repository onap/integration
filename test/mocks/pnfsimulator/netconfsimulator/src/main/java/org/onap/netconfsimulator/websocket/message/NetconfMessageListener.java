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

package org.onap.netconfsimulator.websocket.message;

import java.io.IOException;
import javax.websocket.EncodeException;
import javax.websocket.RemoteEndpoint;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.onap.netconfsimulator.kafka.model.KafkaMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.listener.MessageListener;

public class NetconfMessageListener implements MessageListener<String, String> {

    private static final Logger LOGGER = LoggerFactory.getLogger(NetconfMessageListener.class);
    private RemoteEndpoint.Basic remoteEndpoint;

    public NetconfMessageListener(RemoteEndpoint.Basic remoteEndpoint) {
        this.remoteEndpoint = remoteEndpoint;
    }

    @Override
    public void onMessage(ConsumerRecord<String, String> message) {
        LOGGER.debug("Attempting to send message to {}", remoteEndpoint);
        try {
            remoteEndpoint
                .sendObject(new KafkaMessage(message.timestamp(), message.value()));
        } catch (IOException | EncodeException exception) {
            LOGGER.error("Error during sending message to remote", exception);
        }
    }
}
