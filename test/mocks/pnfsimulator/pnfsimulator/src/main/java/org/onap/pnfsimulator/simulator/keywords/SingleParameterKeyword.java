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
import java.util.Collections;
import java.util.List;
import java.util.regex.Pattern;
import lombok.Getter;
import lombok.Setter;
import lombok.val;

@Patterns
@Getter
@Setter
public class SingleParameterKeyword extends Keyword {

    public static final int KEYWORD_NAME_GROUP = 2;
    public static final int ADDITIONAL_PARAMETER_GROUP = 3;

    private static final String KEYWORD_REGEX = new StringBuilder()
        .append(OPTIONAL.apply(NONLETTERS_REGEX))
        .append("#")
        .append(LETTERS_REGEX)
        .append("\\((\\d+)\\)")
        .append(OPTIONAL.apply(NONLETTERS_REGEX))
        .toString();
    public static final int SKIPPED_GROUP_NUMBER = 3;

    private Integer additionalParameter;

    private SingleParameterKeyword(String name, List<String> meaningfulParts,
        Integer additionalParameter) {
        super(name, meaningfulParts);
        this.additionalParameter = additionalParameter;
    }

    @Unapply
    static Tuple1<SingleParameterKeyword> singleParameterKeyword(String keyword) {
        val matcher = Pattern.compile(KEYWORD_REGEX).matcher(keyword);
        SingleParameterKeyword spk = null;
        if (matcher.find()) {
            spk = new SingleParameterKeyword(
                matcher.group(KEYWORD_NAME_GROUP),
                extractPartsFrom(matcher, Collections.singletonList(SKIPPED_GROUP_NUMBER)),
                Integer.parseInt(matcher.group(ADDITIONAL_PARAMETER_GROUP))
            );
        }
        return Tuple.of(spk);
    }
}


