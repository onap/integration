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

package org.onap.pnfsimulator.template.search;

import com.google.common.base.Strings;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;
import org.bson.Document;

/**
 * This util flattens nested json and produces json with keys transformed to form of json path
 * where default separator between parent object key and object key is ':'
 * For easing searching of boolean values, they are converted to its string representation
 */
public class JsonUtils {

    private static final String DEFAULT_PARENT_KEY_TO_OBJECT_KEY_SEPARATOR = ":";
    private static final String SEED_PREFIX = "";
    private static final Gson GSON = new Gson();

    public JsonObject flatten(JsonObject original) {
        return flattenWithPrefixedKeys(DEFAULT_PARENT_KEY_TO_OBJECT_KEY_SEPARATOR, original.deepCopy(), SEED_PREFIX, new JsonObject());
    }

    public JsonObject flatten(String parentKeyToKeySeparator, JsonObject original) {
        return flattenWithPrefixedKeys(parentKeyToKeySeparator, original.deepCopy(), SEED_PREFIX, new JsonObject());
    }

    public Document flatten(Document original) {
        return flatten(DEFAULT_PARENT_KEY_TO_OBJECT_KEY_SEPARATOR, original);
    }

    public Document flatten(String parentKeyToKeySeparator, Document original) {
        JsonObject originalJsonObject = GSON.fromJson(original.toJson(), JsonObject.class);
        JsonObject flattenedJson = flatten(parentKeyToKeySeparator, originalJsonObject);
        return Document.parse(flattenedJson.toString());
    }

    private JsonObject flattenWithPrefixedKeys(String parentKeyToKeySeparator, JsonElement topLevelElem, String prefix, JsonObject acc) {
        if (topLevelElem.isJsonPrimitive()) {
            handleJsonPrimitive(topLevelElem, prefix, acc);
        } else if (topLevelElem.isJsonArray()) {
            handleJsonArray(parentKeyToKeySeparator, topLevelElem, prefix, acc);
        } else if (topLevelElem.isJsonObject()) {
            handleJsonObject(parentKeyToKeySeparator, topLevelElem, prefix, acc);
        } else {
            acc.add(prefix, topLevelElem.getAsJsonNull());
        }
        return acc.deepCopy();
    }

    private void handleJsonObject(String parentKeyToKeySeparator, JsonElement topLevelElem, String prefix, JsonObject acc) {
        boolean isEmpty = true;
        JsonObject thisToplevelObj = topLevelElem.getAsJsonObject();
        for (String key : thisToplevelObj.keySet()) {
            isEmpty = false;
            String keyPrefix = String.format("%s%s%s", prefix, parentKeyToKeySeparator, key);
            flattenWithPrefixedKeys(parentKeyToKeySeparator, thisToplevelObj.get(key), keyPrefix, acc);
        }
        if (isEmpty && !Strings.isNullOrEmpty(prefix)) {
            acc.add(prefix, new JsonObject());
        }
    }

    private void handleJsonArray(String parentKeyToKeySeparator, JsonElement topLevelElem, String prefix, JsonObject acc) {
        JsonArray asJsonArray = topLevelElem.getAsJsonArray();
        if (asJsonArray.size() == 0) {
            acc.add(prefix, new JsonArray());
        }
        for (int i = 0; i < asJsonArray.size(); i++) {
            flattenWithPrefixedKeys(parentKeyToKeySeparator, asJsonArray.get(i), String.format("%s[%s]", prefix, i), acc);
        }
    }

    private void handleJsonPrimitive(JsonElement topLevelElem, String prefix, JsonObject acc) {
        JsonPrimitive jsonPrimitive = topLevelElem.getAsJsonPrimitive();
        if (jsonPrimitive.isBoolean()) {
            acc.add(prefix, new JsonPrimitive(jsonPrimitive.getAsString()));
        } else {
            acc.add(prefix, topLevelElem.getAsJsonPrimitive());
        }
    }
}
