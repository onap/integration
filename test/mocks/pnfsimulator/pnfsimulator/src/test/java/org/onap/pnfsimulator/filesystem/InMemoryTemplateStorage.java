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

package org.onap.pnfsimulator.filesystem;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import com.google.gson.JsonObject;
import org.onap.pnfsimulator.db.Storage;
import org.onap.pnfsimulator.template.Template;

public class InMemoryTemplateStorage implements Storage<Template> {

  private List<Template> storage = new ArrayList<>();

  @Override
  public List<Template> getAll() {
    return new ArrayList<>(storage);
  }

  @Override
  public Optional<Template> get(String name) {
    return storage.stream().filter(template -> template.getId().equals(name)).findFirst();
  }

  @Override
  public void persist(Template template) {
    if (!storage.contains(template)){
      storage.add(template);
    }
  }

  @Override
  public boolean tryPersistOrOverwrite(Template template, boolean overwrite) {
    if (!storage.contains(template) || overwrite){
      storage.add(template);
      return true;
    }
    return false;
  }

  @Override
  public void delete(String templateName) {
    get(templateName).ifPresent(template -> storage.remove(template));
  }

  @Override
  public List<String> getIdsByContentCriteria(JsonObject queryJson) {
    throw new RuntimeException("Method is not implemented.");
  }

}
