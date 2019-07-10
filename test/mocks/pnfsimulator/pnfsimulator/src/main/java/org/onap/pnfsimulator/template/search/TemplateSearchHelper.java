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

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import org.onap.pnfsimulator.template.search.handler.PrimitiveValueCriteriaBuilder;
import org.onap.pnfsimulator.template.search.viewmodel.FlatTemplateContent;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Component
public class TemplateSearchHelper {
    private static final String PARENT_TO_CHILD_KEY_SEPARATOR = ":"; //compliant with flat json stored in db
    private static final String FLATTENED_JSON_KEY_REGEX = PARENT_TO_CHILD_KEY_SEPARATOR + "%s(?:(\\[[\\d]+\\]))?$";
    private static final String FLATTENED_TEMPLATES_VIEW = "flatTemplatesView";

    private MongoTemplate mongoTemplate;
    private PrimitiveValueCriteriaBuilder criteriaBuilder;

    @Autowired
    public TemplateSearchHelper(MongoTemplate mongoTemplate) {
        this.mongoTemplate = mongoTemplate;
        this.criteriaBuilder = new PrimitiveValueCriteriaBuilder();
    }

    public List<String> getIdsOfDocumentMatchingCriteria(JsonObject jsonCriteria) {
        if (isNullValuePresentInCriteria(jsonCriteria)) {
            throw new IllegalJsonValueException("Null values in search criteria are not supported.");
        }
        Criteria mongoDialectCriteria = composeCriteria(jsonCriteria);
        Query query = new Query(mongoDialectCriteria);
        List<FlatTemplateContent> flatTemplateContents = mongoTemplate.find(query, FlatTemplateContent.class, FLATTENED_TEMPLATES_VIEW);
        return flatTemplateContents
                .stream()
                .map(FlatTemplateContent::getId)
                .collect(Collectors.toList());
    }


    private Criteria composeCriteria(JsonObject criteria) {
        Criteria[] criteriaArr = criteria.entrySet()
                .stream()
                .map(this::mapEntryCriteriaWithRegex)
                .toArray(Criteria[]::new);
        return criteriaArr.length > 0 ? new Criteria().andOperator(criteriaArr) : new Criteria();
    }

    private Criteria mapEntryCriteriaWithRegex(Map.Entry<String, JsonElement> entry) {
        Pattern primitiveOrArrayElemKeyRegex = getCaseInsensitive(String.format(FLATTENED_JSON_KEY_REGEX, entry.getKey()));
        Criteria criteriaForJsonKey = Criteria.where("k").regex(primitiveOrArrayElemKeyRegex);
        Criteria criteriaWithValue = criteriaBuilder.applyValueCriteriaBasedOnPrimitiveType(criteriaForJsonKey.and("v"), entry.getValue().getAsJsonPrimitive());
        return Criteria.where("keyValues").elemMatch(criteriaWithValue);

    }

    private boolean isNullValuePresentInCriteria(JsonObject jsonObject) {
        return jsonObject.entrySet()
                .stream()
                .map(Map.Entry::getValue)
                .anyMatch(JsonElement::isJsonNull);
    }

    static Pattern getCaseInsensitive(String base) {
        return Pattern.compile(base, Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
    }
}


