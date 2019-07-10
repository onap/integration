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

package org.onap.pnfsimulator.event;

import com.google.gson.JsonObject;
import java.util.List;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class EventDataService {
  private final EventDataRepository repository;

  @Autowired
  public EventDataService(EventDataRepository repository) {
    this.repository = repository;
  }

  private EventData persistEventData(String templateString, String patchedString, String inputString, String keywordsString) {
    EventData eventData = EventData.builder()
        .template(templateString)
        .patched(patchedString)
        .input(inputString)
        .keywords(keywordsString)
        .build();
    return repository.save(eventData);
  }

  public EventData persistEventData(JsonObject templateJson, JsonObject patchedJson, JsonObject inputJson,
      JsonObject keywordsJson) {
    return persistEventData(templateJson.toString(),
        patchedJson.toString(),
        inputJson.toString(),
        keywordsJson.toString());
  }

  public List<EventData> getAllEvents() {
    return repository.findAll();
  }

  public Optional<EventData> getById(String id) {
    return repository.findById(id);
  }
}
