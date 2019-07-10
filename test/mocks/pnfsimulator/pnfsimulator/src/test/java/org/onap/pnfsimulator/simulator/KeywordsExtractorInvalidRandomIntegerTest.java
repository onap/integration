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
public class KeywordsExtractorInvalidRandomIntegerTest {

    private final String keyword;
    private KeywordsExtractor keywordsExtractor;

    private static final Collection INVALID_INTEGER_KEYWORDS = Arrays.asList(new Object[][]{
        {"#RandoInteger"},
        {"#Randominteger(23,11)"},
        {"#randomInteger(11,34)"},
        {"#Random_Integer(11,13)"},
        {"#RandomInteger(11)"},
        {"RandomInteger(11)"},
        {"RandomInteger"}
    });

    public KeywordsExtractorInvalidRandomIntegerTest(String keyword) {
        this.keyword = keyword;
    }

    @Before
    public void setUp() {
        this.keywordsExtractor = new KeywordsExtractor();
    }

    @Parameterized.Parameters
    public static Collection data() {
        return INVALID_INTEGER_KEYWORDS;
    }

    @Test
    public void checkValidRandomStringKeyword() {
        assertEquals(keywordsExtractor.substituteStringKeyword(this.keyword, 1), this.keyword);
    }

}
