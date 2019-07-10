/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2018 Nokia. All rights reserved.
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

package org.onap.pnfsimulator.simulator;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.onap.pnfsimulator.event.EventData;
import org.onap.pnfsimulator.event.EventDataRepository;

public class IncrementProviderImplTest {
  private IncrementProvider incrementProvider;

  @Mock
  private EventDataRepository eventDataRepositoryMock;

  @BeforeEach
  void setUp() {
    eventDataRepositoryMock = mock(EventDataRepository.class);
    incrementProvider = new IncrementProviderImpl(eventDataRepositoryMock);
  }

  @Test
  public void getAndIncrementTest() {
    ArgumentCaptor<EventData> eventDataArgumentCaptor = ArgumentCaptor.forClass(EventData.class);
    String eventId = "1";
    int initialIncrementValue = 0;
    int expectedValue = initialIncrementValue + 1;
    EventData eventData = EventData.builder().id(eventId).incrementValue(initialIncrementValue).build();
    Optional<EventData> optional = Optional.of(eventData);

    when(eventDataRepositoryMock.findById(eventId)).thenReturn(optional);

    int value = incrementProvider.getAndIncrement(eventId);

    verify(eventDataRepositoryMock).save(eventDataArgumentCaptor.capture());

    assertThat(value).isEqualTo(expectedValue);
    assertThat(eventDataArgumentCaptor.getValue().getIncrementValue()).isEqualTo(expectedValue);

  }

  @Test
    public void shouldThrowOnNonExistingEvent() {
    Optional<EventData> emptyOptional = Optional.empty();
    String nonExistingEventId = "THIS_DOES_NOT_EXIST";
    when(eventDataRepositoryMock.findById(nonExistingEventId)).thenReturn(emptyOptional);

    assertThrows(EventNotFoundException.class,
        () -> incrementProvider.getAndIncrement(nonExistingEventId));
  }
}
