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
public class KeywordsExtractorValidTimestampTest {

    private final String keyword;
    private final int length;
    private KeywordsExtractor keywordsExtractor;

    private static final Collection VALID_TIMESTAMP_KEYWORDS = Arrays.asList(new Object[][]{
        {"#Timestamp", 10},
        {"#Timestamp12", 10 + 2},
        {"1#Timestamp", 1 + 10},
        {"1#Timestamp2", 1 + 10 +1}
    });

    public KeywordsExtractorValidTimestampTest(String keyword, Integer length) {
        this.keyword = keyword;
        this.length = length;
    }

    @Before
    public void setUp() {
        this.keywordsExtractor = new KeywordsExtractor();
    }

    @Parameterized.Parameters
    public static Collection data() {
        return VALID_TIMESTAMP_KEYWORDS;
    }

    @Test
    public void checkValidRandomStringKeyword() {
        String substitution = keywordsExtractor.substituteStringKeyword(this.keyword, 1);
        assertEquals(substitution.length(), this.length);
    }

}
