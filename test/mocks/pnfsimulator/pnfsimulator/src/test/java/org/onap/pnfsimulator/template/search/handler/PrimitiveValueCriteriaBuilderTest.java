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

import com.google.gson.JsonPrimitive;
import org.junit.jupiter.api.Test;
import org.springframework.data.mongodb.core.query.Criteria;

import static org.assertj.core.api.Java6Assertions.assertThat;

class PrimitiveValueCriteriaBuilderTest {

    private PrimitiveValueCriteriaBuilder builder = new PrimitiveValueCriteriaBuilder();

    @Test
    void testShouldAddRegexLikeCriteriaForStringType(){
        Criteria criteria = builder.applyValueCriteriaBasedOnPrimitiveType(Criteria.where("k").is("10").and("v"), new JsonPrimitive("sample"));

        assertThat(criteria.getCriteriaObject().toJson()).isEqualTo("{ \"k\" : \"10\", \"v\" : { \"$regex\" : \"^\\\\Qsample\\\\E$\", \"$options\" : \"iu\" } }");
    }

    @Test
    void testShouldAddRegexLikeAndEscapeStringWithMetaChars(){
        Criteria criteria = builder.applyValueCriteriaBasedOnPrimitiveType(Criteria.where("k").is("10").and("v"), new JsonPrimitive("[1,2,3,4,5]"));

        assertThat(criteria.getCriteriaObject().toJson()).isEqualTo("{ \"k\" : \"10\", \"v\" : { \"$regex\" : \"^\\\\Q[1,2,3,4,5]\\\\E$\", \"$options\" : \"iu\" } }");
    }

    @Test
    void testShouldAddRegexLikeCriteriaForIntType(){
        Criteria criteria = builder.applyValueCriteriaBasedOnPrimitiveType(Criteria.where("k").is("10").and("v"), new JsonPrimitive(1));

        assertThat(criteria.getCriteriaObject().toJson()).isEqualTo("{ \"k\" : \"10\", \"v\" : 1.0 }");
    }

    @Test
    void testShouldAddRegexLikeCriteriaForLongType(){
        Criteria criteria = builder.applyValueCriteriaBasedOnPrimitiveType(Criteria.where("k").is("10").and("v"), new JsonPrimitive(Long.MAX_VALUE));

        assertThat(criteria.getCriteriaObject().toJson()).isEqualTo("{ \"k\" : \"10\", \"v\" : 9.223372036854776E18 }");
    }

    @Test
    void testShouldAddRegexLikeCriteriaForDoubleType(){
        Criteria criteria = builder.applyValueCriteriaBasedOnPrimitiveType(Criteria.where("k").is("10").and("v"), new JsonPrimitive(2.5));

        assertThat(criteria.getCriteriaObject().toJson()).isEqualTo("{ \"k\" : \"10\", \"v\" : 2.5 }");
    }

    @Test
    void testShouldAddRegexLikeCriteriaForBooleanType(){
        Criteria criteria = builder.applyValueCriteriaBasedOnPrimitiveType(Criteria.where("k").is("10").and("v"), new JsonPrimitive(true));

        assertThat(criteria.getCriteriaObject().toJson()).isEqualTo("{ \"k\" : \"10\", \"v\" : \"true\" }");
    }

}
