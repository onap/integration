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

import org.onap.pnfsimulator.event.EventData;
import org.onap.pnfsimulator.event.EventDataRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class IncrementProviderImpl implements IncrementProvider {
  private final EventDataRepository repository;

  @Autowired
  public IncrementProviderImpl(EventDataRepository repository) {
    this.repository = repository;
  }

  @Override
  public int getAndIncrement(String id) {
    EventData eventData = repository.findById(id)
        .orElseThrow(() -> new EventNotFoundException(id));
    int value = eventData.getIncrementValue() + 1;
    eventData.setIncrementValue(value);
    repository.save(eventData);
    return value;
  }

}
