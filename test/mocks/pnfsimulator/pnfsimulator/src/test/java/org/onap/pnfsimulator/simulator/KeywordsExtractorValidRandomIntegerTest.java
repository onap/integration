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

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.Arrays;
import java.util.Collection;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

@RunWith(Parameterized.class)
public class KeywordsExtractorValidRandomIntegerTest {

    private final String keyword;
    private final String shouldParseTo;
    private KeywordsExtractor keywordsExtractor;

    private static final Collection VALID_INTEGER_KEYWORDS = Arrays.asList(new Object[][]{
        {"#RandomInteger(23,23)", "23"},
        {"#RandomInteger(6, 6)12", "612"},
        {"1#RandomInteger(11,11)", "111"},
        {"1#RandomInteger(11,11)2", "1112"}
    });

    public KeywordsExtractorValidRandomIntegerTest(String keyword, String shouldParseTo) {
        this.keyword = keyword;
        this.shouldParseTo = shouldParseTo;
    }

    @Before
    public void setUp() {
        this.keywordsExtractor = new KeywordsExtractor();
    }

    @Parameterized.Parameters
    public static Collection data() {
        return VALID_INTEGER_KEYWORDS;
    }

    @Test
    public void checkValidRandomStringKeyword() {
        assertEquals(keywordsExtractor.substituteStringKeyword(this.keyword, 1), this.shouldParseTo);
    }

}
