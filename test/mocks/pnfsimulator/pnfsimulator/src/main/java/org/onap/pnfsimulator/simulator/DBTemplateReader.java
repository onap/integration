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

package org.onap.pnfsimulator.simulator;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import java.io.IOException;
import org.onap.pnfsimulator.template.Template;
import org.onap.pnfsimulator.template.TemplateService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class DBTemplateReader implements TemplateReader {
  private final TemplateService service;
  private final Gson gson;

  @Autowired
  public DBTemplateReader(TemplateService service, Gson gson) {
    this.service = service;
    this.gson = gson;
  }

  @Override
  public JsonObject readTemplate(String templateName) throws IOException {
    Template template = service.get(templateName).orElseThrow(() -> new IOException("Template does not exist"));
    JsonElement jsonElement = gson.toJsonTree(template.getContent());
    return jsonElement.getAsJsonObject();
  }
}
