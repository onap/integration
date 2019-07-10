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


import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.MockitoAnnotations.initMocks;

import java.io.IOException;
import javax.websocket.EncodeException;
import javax.websocket.RemoteEndpoint;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.onap.netconfsimulator.kafka.model.KafkaMessage;


class NetconfMessageListenerTest {

    private static final ConsumerRecord<String, String> KAFKA_RECORD = new ConsumerRecord<>("sampleTopic", 0, 0,
        "sampleKey", "sampleValue");

    @Mock
    private RemoteEndpoint.Basic remoteEndpoint;

    @InjectMocks
    private NetconfMessageListener netconfMessageListener;


    @BeforeEach
    void setUp() {
        initMocks(this);
    }


    @Test
    void shouldProperlyParseAndSendConsumerRecord() throws IOException, EncodeException {
        netconfMessageListener.onMessage(KAFKA_RECORD);

        verify(remoteEndpoint).sendObject(any(KafkaMessage.class));
    }



    @Test
    void shouldNotPropagateEncodeException() throws IOException, EncodeException {
        doThrow(new EncodeException("","")).when(remoteEndpoint).sendObject(any(KafkaMessage.class));

        netconfMessageListener.onMessage(KAFKA_RECORD);
    }
}
