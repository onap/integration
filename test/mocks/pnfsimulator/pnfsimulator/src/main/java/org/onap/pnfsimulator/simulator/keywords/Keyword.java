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

import io.vavr.Function1;
import io.vavr.Function2;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.stream.Collectors;
import lombok.Getter;

@Getter
public class Keyword {

    protected static final String LETTERS_REGEX = "([a-zA-Z]+)";
    protected static final String NONLETTERS_REGEX = "([^a-zA-Z]+)";

    protected static final Function1<String, String> OPTIONAL =
            (regex) -> regex + "?";

    private final String name;
    private final List<String> meaningfulParts;

    public static final Function2<Keyword, String, Boolean> IS_MATCHING_KEYWORD_NAME = (keyword, key) ->
        keyword != null && keyword.getName() != null && keyword.getName().equals(key);

    /**
     * Returns list of independent parts inside the keyword. Current implementation assumes that customer can join keywords with integer values, so
     * keyword is decomposed to parts then some parts of the keyword is skipped because of replacement process.
     *
     * @param matcher - Matcher to check find independent groups inside the keyword
     * @param skipGroups Informs this method about which groups should be consider as part of the replacement process
     * @return list of independent parts inside the keywords
     */
    static List<String> extractPartsFrom(Matcher matcher, List skipGroups) {
        List<String> parts = new ArrayList<String>();
        for (int i = 1; i <= matcher.groupCount(); i++) {
            if (matcher.group(i) != null && !skipGroups.contains(i)) {
                parts.add(matcher.group(i));
            }
        }
        return parts;
    }

    Keyword(String name, List<String> meaningfulParts) {
        this.name = name;
        this.meaningfulParts = meaningfulParts;
    }

    public String substituteKeyword(String substitution) {
        return meaningfulParts.stream()
            .map(part -> part.equals(name) ? substitution : part)
            .collect(Collectors.joining());
    }

}
