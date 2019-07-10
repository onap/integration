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

package org.onap.pnfsimulator.template.search.handler;

import com.google.common.collect.Lists;
import com.google.gson.JsonPrimitive;
import org.springframework.data.mongodb.core.query.Criteria;

import java.util.List;
import java.util.regex.Pattern;

/**
 * This class is a helper class for constructing apropriate criteria for query send to mongodb based on type of value.
 * Query is build to search mongodb for templates that contains key-value pairs that satisfy given criteria.
 * Value is oftype JsonPrimitive, based on its primitive java type following criteria are build to get proper document:
 * -for string - there is a regex expression that ignores every meta character inside passed argument and searches for exact literal match ignoring case;
 * -for number - all numbers are treated as double (mongodb number type equivalent)
 * -for boolean - exact match, used string representation of boolean in search
 **/

public class PrimitiveValueCriteriaBuilder {

    private final List<ValueTypeHandler> typeHandlers;

    public PrimitiveValueCriteriaBuilder() {
        typeHandlers = Lists.newArrayList(new StringValueHandler(), new NumberValueHandler(), new BoolValueHandler());
    }

    public Criteria applyValueCriteriaBasedOnPrimitiveType(Criteria baseCriteria, JsonPrimitive jsonPrimitive) {
        ValueTypeHandler typeHandler = typeHandlers.stream()
                .filter(el -> el.isProperTypeHandler(jsonPrimitive))
                .findFirst()
                .orElseThrow(() ->
                        new IllegalArgumentException(String.format(
                                "Expected json primitive, but given value: %s is of type: %s and could not be decoded",
                                jsonPrimitive, jsonPrimitive.getClass().toString())));
        return typeHandler.chainCriteriaForValue(baseCriteria, jsonPrimitive);
    }

    private interface ValueTypeHandler {
        boolean isProperTypeHandler(JsonPrimitive value);

        Criteria chainCriteriaForValue(Criteria criteria, JsonPrimitive value);
    }

    private class BoolValueHandler implements ValueTypeHandler {
        public boolean isProperTypeHandler(JsonPrimitive value) {
            return value.isBoolean();
        }

        public Criteria chainCriteriaForValue(Criteria criteria, JsonPrimitive value) {
            return criteria.is(value.getAsString());
        }

    }

    private class NumberValueHandler implements ValueTypeHandler {
        public boolean isProperTypeHandler(JsonPrimitive value) {
            return value.isNumber();
        }

        public Criteria chainCriteriaForValue(Criteria baseCriteria, JsonPrimitive value) {
            return baseCriteria.is(value.getAsDouble());
        }
    }

    private class StringValueHandler implements ValueTypeHandler {
        public boolean isProperTypeHandler(JsonPrimitive value) {
            return value.isString();
        }

        public Criteria chainCriteriaForValue(Criteria baseCriteria, JsonPrimitive value) {
            return baseCriteria.regex(makeRegexCaseInsensitive(value.getAsString()));
        }

        private Pattern makeRegexCaseInsensitive(String base) {
            String metaCharEscaped = convertToIgnoreMetaChars(base);
            return Pattern.compile("^" + metaCharEscaped + "$", Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
        }

        private String convertToIgnoreMetaChars(String valueWithMetaChars) {
            return Pattern.quote(valueWithMetaChars);
        }
    }
}
