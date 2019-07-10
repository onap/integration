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
package org.onap.pnfsimulator.simulator.keywords;

import io.vavr.Tuple;
import io.vavr.Tuple1;
import io.vavr.match.annotation.Patterns;
import io.vavr.match.annotation.Unapply;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;
import lombok.Getter;
import lombok.Setter;
import lombok.val;

@Patterns
@Getter
@Setter
public class TwoParameterKeyword extends Keyword {

    public static final int ADDITIONAL_PARAMETER_1_GROUP = 3;
    public static final int ADDITIONAL_PARAMETER_2_GROUP = 4;
    public static final int KEYWORD_NAME_GROUP = 2;
    protected static final List<Integer> ADDITIONAL_PARAMETERS_GROUPS = Arrays.asList(ADDITIONAL_PARAMETER_1_GROUP, ADDITIONAL_PARAMETER_2_GROUP);

    private static final String NON_LIMITED_NUMBER_REGEX = "\\((\\d+)";
    private static final String COLON_REGEX = "\\s?,\\s?";
    private static final String OPTIONAL_NUMBER_PARAM_REGEX = "(\\d+)\\)";

    private static final String KEYWORD_REGEX = OPTIONAL.apply(NONLETTERS_REGEX)
        + "#"
        + LETTERS_REGEX
        + NON_LIMITED_NUMBER_REGEX
        + COLON_REGEX
        + OPTIONAL_NUMBER_PARAM_REGEX
        + OPTIONAL.apply(NONLETTERS_REGEX);

    private Integer additionalParameter1;
    private Integer additionalParameter2;

    private TwoParameterKeyword(String name, List<String> meaningfulParts, Integer additionalParameter1,
        Integer additionalParameter2) {
        super(name, meaningfulParts);
        this.additionalParameter1 = additionalParameter1;
        this.additionalParameter2 = additionalParameter2;
    }

    @Unapply
    static Tuple1<TwoParameterKeyword> twoParameterKeyword(String keyword) {
        val matcher = Pattern.compile(KEYWORD_REGEX).matcher(keyword);
        TwoParameterKeyword tpk = null;
        if (matcher.find()) {
            tpk = new TwoParameterKeyword(
                matcher.group(KEYWORD_NAME_GROUP),
                extractPartsFrom(matcher, ADDITIONAL_PARAMETERS_GROUPS),
                Integer.parseInt(matcher.group(ADDITIONAL_PARAMETER_1_GROUP)),
                Integer.parseInt(matcher.group(ADDITIONAL_PARAMETER_2_GROUP))
            );
        }
        return Tuple.of(tpk);
    }

}
