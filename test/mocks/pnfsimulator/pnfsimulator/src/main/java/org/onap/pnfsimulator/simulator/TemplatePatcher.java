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

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
class TemplatePatcher {

    JsonObject mergeTemplateWithPatch(JsonObject templateJson, JsonObject patchJson) {
        JsonObject template = templateJson.deepCopy();
        patchTemplateNode(template, patchJson);
        return template;
    }

    private void patchTemplateNode(JsonObject templateJson, JsonObject patchJson) {
        for (Map.Entry<String, JsonElement> stringJsonElementEntry : patchJson.entrySet()) {
            String patchKey = stringJsonElementEntry.getKey();
            JsonElement patchValue = stringJsonElementEntry.getValue();
            JsonElement templateElement = templateJson.get(patchKey);

            if (!patchValue.isJsonObject() || templateElement == null || !templateElement.isJsonObject()) {
                templateJson.remove(patchKey);
                templateJson.add(patchKey, patchValue);
            } else {
                patchTemplateNode(templateElement.getAsJsonObject(), patchValue.getAsJsonObject());
            }

        }
    }
}
