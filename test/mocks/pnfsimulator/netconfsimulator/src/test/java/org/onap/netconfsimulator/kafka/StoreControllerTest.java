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

import java.time.Instant;
import java.util.List;
import org.assertj.core.api.Assertions;
import org.assertj.core.util.Lists;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import static org.mockito.Mockito.when;

@RunWith(SpringJUnit4ClassRunner.class)
public class StoreControllerTest {

    private static final String MESSAGE_3 = "message 3";
    private static final String MESSAGE_2 = "message 2";
    private static final String MESSAGE_1 = "message 1";

    private static final List<MessageDTO> ALL_MESSAGES = Lists.newArrayList(new MessageDTO(Instant.now().getEpochSecond(), MESSAGE_1),
            new MessageDTO(Instant.now().getEpochSecond(), MESSAGE_2),
            new MessageDTO(Instant.now().getEpochSecond(), MESSAGE_3));

    @Mock
    private StoreService service;

    @InjectMocks
    private StoreController storeController;


    @Test
    public void lessShouldTakeAllMessagesTest() {
        when(service.getLastMessages(3)).thenReturn(ALL_MESSAGES);

        List<MessageDTO> lessResponse = storeController.less(3);

        assertResponseContainsExpectedMessages(lessResponse, 3, MESSAGE_1, MESSAGE_2, MESSAGE_3);
    }

    @Test
    public void lessShouldTakeTwoMessagesTest() {
        when(service.getLastMessages(2)).thenReturn(Lists.newArrayList(new MessageDTO(Instant.now().getEpochSecond(), MESSAGE_1)));

        List<MessageDTO> lessResult = storeController.less(2);

        assertResponseContainsExpectedMessages(lessResult, 1, MESSAGE_1);
    }

    @Test
    public void shouldGetAllMessages(){
        when(service.getAllMessages()).thenReturn(ALL_MESSAGES);

        List<MessageDTO> allMsgResult = storeController.getAllConfigurationChanges();

        assertResponseContainsExpectedMessages(allMsgResult, 3, MESSAGE_1, MESSAGE_2, MESSAGE_3);
    }

    private void assertResponseContainsExpectedMessages(List<MessageDTO> actualMessages, int expectedMessageCount, String... expectedMessages){
        Assertions.assertThat(actualMessages.stream().map(MessageDTO::getConfiguration))
                .hasSize(expectedMessageCount)
                .containsExactly(expectedMessages);
    }

}
