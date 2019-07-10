/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
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

package org.onap.pnfsimulator.simulator;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import java.time.Instant;
import java.util.Arrays;
import java.util.Collection;

import static org.assertj.core.api.Assertions.assertThat;

@RunWith(Parameterized.class)
public class KeywordsExtractorValidTimestampPrimitiveTest {
    private final String keyword;
    private KeywordsExtractor keywordsExtractor;

    private static final Collection VALID_TIMESTAMP_KEYWORDS = Arrays.asList(new Object[][]{
            {"#TimestampPrimitive"}
    });

    public KeywordsExtractorValidTimestampPrimitiveTest(String keyword) {
        this.keyword = keyword;
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
        long currentTimestamp = Instant.now().getEpochSecond();
        Long timestamp = keywordsExtractor.substitutePrimitiveKeyword(this.keyword);
        long afterExecution = Instant.now().getEpochSecond();

        assertThat(timestamp).isBetween(currentTimestamp, afterExecution);
    }

}
