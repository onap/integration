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

import static io.vavr.API.$;
import static io.vavr.API.Case;
import static io.vavr.API.Match;
import static org.onap.pnfsimulator.simulator.KeywordsValueProvider.getEpochSecond;
import static org.onap.pnfsimulator.simulator.KeywordsValueProvider.getRandomLimitedInteger;
import static org.onap.pnfsimulator.simulator.KeywordsValueProvider.getRandomInteger;
import static org.onap.pnfsimulator.simulator.KeywordsValueProvider.getRandomLimitedString;
import static org.onap.pnfsimulator.simulator.KeywordsValueProvider.getRandomString;
import static org.onap.pnfsimulator.simulator.KeywordsValueProvider.getRandomPrimitiveInteger;
import static org.onap.pnfsimulator.simulator.KeywordsValueProvider.getTimestampPrimitive;
import static org.onap.pnfsimulator.simulator.keywords.NonParameterKeywordPatterns.$nonParameterKeyword;
import static org.onap.pnfsimulator.simulator.keywords.SingleParameterKeywordPatterns.$singleParameterKeyword;
import static org.onap.pnfsimulator.simulator.keywords.TwoParameterKeywordPatterns.$twoParameterKeyword;
import io.vavr.API.Match.Pattern1;
import org.onap.pnfsimulator.simulator.keywords.Keyword;
import org.onap.pnfsimulator.simulator.keywords.NonParameterKeyword;
import org.onap.pnfsimulator.simulator.keywords.SingleParameterKeyword;
import org.onap.pnfsimulator.simulator.keywords.TwoParameterKeyword;
import org.springframework.stereotype.Component;

@Component
public class KeywordsExtractor {

    String substituteStringKeyword(String text, int increment) {
        return Match(text).of(
                Case(isRandomStringParamKeyword(),
                        spk -> spk.substituteKeyword(getRandomString().apply(spk.getAdditionalParameter()))),
                Case(isRandomStringNonParamKeyword(),
                        npk -> npk.substituteKeyword(getRandomLimitedString().apply())),
                Case(isRandomIntegerParamKeyword(),
                        tpk -> tpk.substituteKeyword(getRandomInteger().apply(tpk.getAdditionalParameter1(), tpk.getAdditionalParameter2()))),
                Case(isRandomIntegerNonParamKeyword(),
                        npk -> npk.substituteKeyword(getRandomLimitedInteger().apply())),
                Case(isIncrementKeyword(),
                        ik -> ik.substituteKeyword(String.valueOf(increment))),
                Case(isTimestampNonParamKeyword(),
                        npk -> npk.substituteKeyword(getEpochSecond().apply())),
                Case(
                        $(),
                        () -> text
                ));
    }

    Long substitutePrimitiveKeyword(String text) {
        return Match(text).of(
                Case(isRandomPrimitiveIntegerParamKeyword(),
                        tpk ->
                                getRandomPrimitiveInteger().apply(tpk.getAdditionalParameter1(), tpk.getAdditionalParameter2())),
                Case(isTimestampPrimitiveNonParamKeyword(),
                        tpk ->
                                getTimestampPrimitive().apply()),
                Case(
                        $(),
                        () -> 0L
                ));
    }

    boolean isPrimitive(String text) {
        return Match(text).of(
                Case(isRandomPrimitiveIntegerParamKeyword(), () -> true),
                Case(isTimestampPrimitiveNonParamKeyword(), () -> true),
                Case($(), () -> false));
    }

    private Pattern1<String, SingleParameterKeyword> isRandomStringParamKeyword() {
        return $singleParameterKeyword($(spk -> Keyword.IS_MATCHING_KEYWORD_NAME.apply(spk, "RandomString")));
    }

    private Pattern1<String, NonParameterKeyword> isRandomStringNonParamKeyword() {
        return $nonParameterKeyword($(npk -> Keyword.IS_MATCHING_KEYWORD_NAME.apply(npk, "RandomString")));
    }

    private Pattern1<String, NonParameterKeyword> isIncrementKeyword() {
        return $nonParameterKeyword($(npk -> Keyword.IS_MATCHING_KEYWORD_NAME.apply(npk, "Increment")));
    }

    private Pattern1<String, TwoParameterKeyword> isRandomIntegerParamKeyword() {
        return $twoParameterKeyword($(tpk -> Keyword.IS_MATCHING_KEYWORD_NAME.apply(tpk, "RandomInteger")));
    }

    private Pattern1<String, TwoParameterKeyword> isRandomPrimitiveIntegerParamKeyword() {
        return $twoParameterKeyword($(tpk -> Keyword.IS_MATCHING_KEYWORD_NAME.apply(tpk, "RandomPrimitiveInteger")));
    }

    private Pattern1<String, NonParameterKeyword> isTimestampPrimitiveNonParamKeyword() {
        return $nonParameterKeyword($(npk -> Keyword.IS_MATCHING_KEYWORD_NAME.apply(npk, "TimestampPrimitive")));
    }

    private Pattern1<String, NonParameterKeyword> isRandomIntegerNonParamKeyword() {
        return $nonParameterKeyword($(npk -> Keyword.IS_MATCHING_KEYWORD_NAME.apply(npk, "RandomInteger")));
    }

    private Pattern1<String, NonParameterKeyword> isTimestampNonParamKeyword() {
        return $nonParameterKeyword($(npk -> Keyword.IS_MATCHING_KEYWORD_NAME.apply(npk, "Timestamp")));
    }

}
